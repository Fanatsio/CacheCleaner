# CacheCleaner - Скрипт для очистки кэша Windows

![PowerShell](https://img.shields.io/badge/PowerShell-%235391FE.svg?style=for-the-badge&logo=powershell&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)

**CacheCleaner** - это PowerShell-скрипт для автоматической очистки временных файлов и системного кэша в Windows. Скрипт выполняет комплексную очистку с минимальным вмешательством пользователя и поддерживает автоматический режим работы. 

## Основные функции

- 🗑️ Очистка системной папки Temp (только старые файлы)
- 📁 Очистка пользовательской папки %Temp%
- 🌐 Сброс DNS-кэша
- 🗂️ Очистка корзины (с возможностью отключения)
- ⚙️ Автоматический режим работы (для автоматизации)
- 🛡️ Автоматический запрос прав администратора

## Требования

- Windows 7/8/10/11
- PowerShell 5.1 или новее
- Права администратора (запрашиваются автоматически)

## Установка и использование

### Вариант 1: Запуск скрипта (PowerShell)

1. Скачайте скрипт `CacheCleaner.ps1`
2. Откройте PowerShell с правами администратора:
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. Запустите скрипт:
   ```powershell
   .\CacheCleaner.ps1
   ```

### Вариант 2: Исполняемый файл (EXE)

В папке `build` доступна готовая версия в формате EXE:

1. Скачайте `CacheCleaner.exe`
2. Запустите от имени администратора

## Параметры запуска

| Параметр         | Описание                                 |
|------------------|------------------------------------------|
| `-AutoConfirm`   | Автоматическое подтверждение операций    |
| `-SkipRecycleBin`| Пропустить очистку корзины               |

Примеры:
```powershell
# Полная автоматизация (без подтверждения и без корзины)
.\CacheCleaner.ps1 -AutoConfirm -SkipRecycleBin

# Только очистка системных кэшей (с подтверждением)
.\CacheCleaner.ps1
```

## Сборка EXE-версии

Для компиляции в исполняемый файл:

1. Установите модуль PS2EXE:
   ```powershell
   Install-Module -Name PS2EXE -Force
   ```
2. Выполните компиляцию:
   ```powershell
   Invoke-PS2EXE -InputFile .\src\CacheCleaner.ps1 -OutputFile .\build\CacheCleaner.exe -IconFile .\build\icon.ico -RequireAdmin
   ```

## Меры предосторожности

1. Скрипт удаляет только старые файлы (системные Temp >1 дня, пользовательские Temp >7 дней)
2. Исключает критические папки установщика Windows
3. Всегда запрашивает подтверждение (кроме авторежима)
4. Предоставляет опцию пропуска очистки корзины

## Лицензия

Проект распространяется под лицензией MIT. Подробнее см. в файле [LICENSE](LICENSE).