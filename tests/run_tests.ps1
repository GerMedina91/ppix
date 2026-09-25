# Corre los tests con gdUnit4 desde la línea de comandos.
# Uso (desde cualquier carpeta):
#   pwsh tests/run_tests.ps1            todos (antes de cada push)
#   pwsh tests/run_tests.ps1 -Rapidos   sin tests/integracion/ (escenas completas del mundo; en cada paso)
# Ejecutable de Godot: variable de entorno GODOT_BIN o la ruta de instalación por defecto.
# Se llama a Godot directo (sin runtest.cmd) para evitar el debugger remoto falso de ese script,
# que imprime errores de conexión al puerto 0. Sin debugger, los errores de script igual fallan el test.
param([switch]$Rapidos)
$ErrorActionPreference = "Stop"
$raiz = Split-Path -Parent $PSScriptRoot
$godot = if ($env:GODOT_BIN) { $env:GODOT_BIN } else {
    Join-Path $env:LOCALAPPDATA "Programs\Godot\Godot_v4.7.2-stable_win64_console.exe"
}
if (-not (Test-Path $godot)) {
    Write-Error "No se encontró Godot en '$godot'. Definí GODOT_BIN con la ruta al ejecutable *_console.exe."
}
$filtro = if ($Rapidos) { @("-i", "res://tests/integracion") } else { @() }
Push-Location $raiz
try {
    # Importar recursos primero (necesario en un clon limpio, sin .godot/)
    & $godot --headless --path . --import | Out-Null
    & $godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://tests @filtro @args
    $codigo = $LASTEXITCODE
    # Copia el log de Godot al reporte HTML
    & $godot --headless --path . --quiet -s res://addons/gdUnit4/bin/GdUnitCopyLog.gd @args | Out-Null
    exit $codigo
}
finally {
    Pop-Location
}
