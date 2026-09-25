# Corre todos los tests con gdUnit4 desde la línea de comandos.
# Uso (desde cualquier carpeta):  pwsh tests/run_tests.ps1
# Ejecutable de Godot: variable de entorno GODOT_BIN o la ruta de instalación por defecto.
$ErrorActionPreference = "Stop"
$raiz = Split-Path -Parent $PSScriptRoot
if (-not $env:GODOT_BIN) {
    $env:GODOT_BIN = Join-Path $env:LOCALAPPDATA "Programs\Godot\Godot_v4.7.2-stable_win64_console.exe"
}
Push-Location $raiz
try {
    # Importar recursos primero (necesario en un clon limpio, sin .godot/)
    & $env:GODOT_BIN --headless --path . --import | Out-Null
    & (Join-Path $raiz "addons\gdUnit4\runtest.cmd") --headless --ignoreHeadlessMode -a res://tests @args
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
