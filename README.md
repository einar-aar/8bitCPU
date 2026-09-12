# Enkel 8-bits CPU

Dette er en liten akkumulatorbasert CPU skrevet i SystemVerilog. Databussen,
adressebussen og programtelleren er 8 bit. Program og data ligger i hvert sitt
minne, så CPU-en kan hente neste instruksjon uten å dele databussen.

## Oppbygning

- `rtl/cpu8.sv` inneholder styring, akkumulator og flagg.
- `rtl/alu.sv` utfører regne- og bitoperasjoner.
- `rtl/program_rom.sv` laster et program fra en hex-fil.
- `rtl/data_ram.sv` er 256 byte arbeidsminne.
- `rtl/cpu8_system.sv` kobler delene sammen.
- `tb/cpu8_tb.sv` tester løkke, minne, summering, hopp og carry-flagg.

CPU-en bruker én byte til opcode. Instruksjoner med argument bruker neste byte
som verdi eller adresse. En slik instruksjon tar tre klokkeslag. Instruksjoner
uten argument tar to.

## Instruksjoner

| Opcode | Navn | Virkning |
|---:|:---|:---|
| `00` | NOP | Gjør ingenting |
| `10 nn` | LDI | Last `nn` i akkumulatoren |
| `11 aa` | LDA | Last fra dataadresse `aa` |
| `12 aa` | STA | Lagre til dataadresse `aa` |
| `20 aa` | ADD | Legg minneverdien til akkumulatoren |
| `21 aa` | SUB | Trekk minneverdien fra akkumulatoren |
| `22 aa` | AND | Bitvis AND |
| `23 aa` | OR | Bitvis OR |
| `24 aa` | XOR | Bitvis XOR |
| `25 nn` | ADI | Legg konstanten `nn` til akkumulatoren |
| `30 aa` | JMP | Hopp til programadresse `aa` |
| `31 aa` | JZ | Hopp hvis resultatet var null |
| `32 aa` | JC | Hopp hvis carry er satt |
| `40` | OUT | Send akkumulatoren til utgangen |
| `ff` | HLT | Stopp CPU-en |

Ukjente opkoder behandles som NOP. `OUT` setter `out_strobe` høyt i én
klokkeperiode. Reset er synkron og aktiv høy. Regne- og logikkoperasjoner
oppdaterer null- og carry-flagg. For subtraksjon betyr carry at det ikke ble
lån. `LDI` oppdaterer nullflagget og nullstiller carry.

## Simulering

Med Icarus Verilog installert kan testen kjøres fra prosjektmappen:

```powershell
.\run_test.ps1
```

Testprogrammet summerer tallene 1 til 10, sjekker resultatet i RAM og prøver
et betinget hopp etter en addisjon som gir carry. En vellykket kjøring skriver
`PASS: CPU-test fullfort`.
