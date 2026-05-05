---
name: django-startup
description: >
  Guía de arranque para proyectos Django modernos con soft delete, domain model puro,
  HTMX 4 + Alpine.js, y Django Ninja para APIs. Trigger: When starting a new Django project,
  scaffolding Django apps, setting up project structure, or initializing a Django codebase.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When to Use

- Iniciando un proyecto Django desde cero
- Scaffolding de una nueva app dentro de un proyecto Django existente
- Revisando la estructura de un proyecto Django para alinearlo con buenas prácticas
- Decidiendo stack frontend (HTMX vs API vs SPA) para un proyecto Django
- Configurando testing, linting, o tooling de un proyecto Django

## Critical Patterns

### 1. Estructura de apps moderna

Si una app tiene más de 3 modelos, `admin.py` y `models.py` deben ser **directorios**, no archivos:

```
app/
├── admin/
│   ├── __init__.py
│   └── model_admin.py
├── models/
│   ├── __init__.py
│   └── model.py
├── domain/           # Lógica pura, sin imports de Django
├── services/         # Use cases / orquestación
├── tests/
│   ├── conftest.py
│   ├── models/
│   └── domain/
└── views.py
```

### 2. BaseModel con soft delete universal

Todos los modelos heredan de `BaseModel`. Siempre dos managers: `objects` (activos) y `all_objects` (todos).

```python
class SoftDeleteManager(models.Manager):
    def get_queryset(self):
        return super().get_queryset().filter(deleted_at__isnull=True)

class BaseModel(models.Model):
    deleted_at = models.DateTimeField(null=True, blank=True, editable=False)
    objects = SoftDeleteManager()
    all_objects = models.Manager()

    def delete(self, *args, **kwargs):
        self.deleted_at = timezone.now()
        self.save(update_fields=["deleted_at", "updated_at"])

    class Meta:
        abstract = True
```

### 3. Domain Model puro

Lógica de negocio en `domain/` usando `dataclass(frozen=True)` + `Protocol`. Testeable sin base de datos.

```python
# app/domain/pricing.py
from dataclasses import dataclass
from decimal import Decimal
from typing import Protocol

@dataclass(frozen=True)
class PriceBreakdown:
    unit_cost: Decimal

class PricingConfig(Protocol):
    show_utilidad: bool
```

### 4. Sin side effects en save()

Los modelos NO crean otros modelos al guardarse. Las automatizaciones van a signals o servicios de aplicación.

```python
# MAL: dentro del modelo
class Person(BaseModel):
    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)
        if self.is_client:
            Deal.objects.create(person=self)

# BIEN: signal separada
@receiver(post_save, sender=Person)
def create_deal_for_client(sender, instance, created, **kwargs):
    if created and instance.is_client:
        Deal.objects.create(person=instance)
```

### 5. Decisiones de stack según contexto

| Si necesitas... | Usá | No uses |
|----------------|-----|---------|
| CRUDs, formularios, tablas | HTMX 4 + Alpine.js + Tailwind | Vue, React, Inertia |
| API para SPA externo/mobile | Django Ninja | DRF (más verboso) |
| Interactividad ligera | Alpine.js | React por 3 componentes |
| Actualizaciones parciales | HTMX 4 | Fetch API manual |
| Base de datos prod | PostgreSQL | SQLite |

**Regla:** No actives una capa "por si acaso". Esperá a que surja la necesidad real.

### 6. Settings seguras

- `DEBUG` nunca hardcodeado. Default: `False`.
- `SECRET_KEY` siempre desde `os.environ` (explota si no está).
- `.env` en `.gitignore`, `.env.example` versionado.

### 7. Decimal siempre con strings

```python
# Bien
Decimal("0.00")
# Mal
Decimal(0.1)  # float pollution
```

## Code Examples

### Scaffolding de app completa

```bash
# Crear app
django-admin startapp quoting

# Crear estructura de directorios
mkdir -p quoting/{admin,models,domain,services,tests/{models,domain}}
touch quoting/{admin,models,tests}/__init__.py

# Base model heredando
cat > quoting/models/quote.py << 'EOF'
from core.models import BaseModel

class Quote(BaseModel):
    # tu modelo
    pass
EOF
```

### Configuración mínima de pytest

```ini
# pytest.ini
[pytest]
DJANGO_SETTINGS_MODULE = config.settings
python_files = tests.py test_*.py *_tests.py
```

```toml
# pyproject.toml (fragmento)
[dependency-groups]
dev = [
    "pytest-django>=4.11",
    "model-bakery>=1.20",
    "pytest-mock>=3.14",
    "ruff>=0.6",
]
```

### GlobalConfiguration singleton

```python
class GlobalConfiguration(BaseModel):
    @classmethod
    def get_solo(cls):
        config = cache.get("global_config")
        if not config:
            config = cls.objects.order_by("-created_at").first()
            if not config:
                config = cls.objects.create()
            cache.set("global_config", config, 3600)
        return config

    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)
        cache.delete("global_config")
```

## Commands

```bash
# Verificar consistencia de versiones
cat .python-version && grep pythonVersion pyrightconfig.json && grep requires-python pyproject.toml

# Crear estructura de app moderna
mkdir -p {app}/{admin,models,domain,services,tests/{models,domain}} && touch {app}/{admin,models,tests}/__init__.py

# Formatear y lintear
uvx ruff format . && uvx ruff check --select I --fix .

# Correr tests
cd /path/to/project && pytest

# Verificar que no hay código muerto de frontend (Vue/Inertia)
grep -r "inertia\|vue\|react" config/settings.py package.json 2>/dev/null || echo "Limpio"
```

## Checklist de arranque

- [ ] `.python-version`, `pyproject.toml`, `pyrightconfig.json` coinciden en versión de Python
- [ ] `DEBUG` lee de env var y default es `False`
- [ ] `.env` en `.gitignore`; `.env.example` versionado
- [ ] `BaseModel` existe con soft delete y dos managers
- [ ] `GlobalConfiguration` existe como singleton con cache
- [ ] Al menos un modelo tiene lógica pura en `domain/`
- [ ] `save()` de modelos no crea otros modelos
- [ ] `ruff` y `pyright` en `dev` dependencies
- [ ] `pytest` corre y al menos un test de dominio pasa sin DB
- [ ] No hay dependencias "por si acaso" instaladas

## Resources

- **Guía completa**: See [assets/startup-guide.md](assets/startup-guide.md) for the full startup guide with detailed explanations, patterns, and conventions.
