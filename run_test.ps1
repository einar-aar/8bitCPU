$ErrorActionPreference = "Stop"

if (-not (Get-Command iverilog -ErrorAction SilentlyContinue)) {
    throw "Icarus Verilog (iverilog) finnes ikke i PATH."
}

New-Item -ItemType Directory -Force -Path "build" | Out-Null

iverilog -g2012 -s cpu8_tb -o build/cpu8_tb.vvp `
    rtl/alu.sv `
    rtl/cpu8.sv `
    rtl/data_ram.sv `
    rtl/program_rom.sv `
    rtl/cpu8_system.sv `
    tb/cpu8_tb.sv

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

vvp build/cpu8_tb.vvp
exit $LASTEXITCODE
