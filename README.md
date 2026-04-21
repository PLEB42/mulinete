# Mulineti

![mulineti](mini-moulinette.jpg)

A local test runner for 42 School assignments. Run automated checks against your code before submitting — covering Piscine, Piscine Reloaded, and Common Core projects.

---

## What It Does

Mulineti runs your exercises through a sandboxed evaluation pipeline that mirrors how the real moulinette grades your work:

- **Norminette validation** — fails the exercise on style violations before wasting time compiling
- **Compilation** — builds with `-Wall -Werror -Wextra` using the same flags as 42
- **Functional tests** — executes the compiled binary and checks expected output
- **Shell evaluation** — runs `run_test.sh` scripts for Shell and Reloaded modules
- **Chain failure** — once an exercise fails, subsequent ones are graded as "Locked" (matching 42's cascade scoring)
- **Log file** — saves a clean, ANSI-stripped report to `logs/<module>.txt`

---

## Supported Modules

| Module      | Type   | Status        | Notes                                      |
| :---------- | :----: | :-----------: | :----------------------------------------- |
| Shell00     | Shell  | Supported     | ex05/ex06 skipped (requires Git env)       |
| Shell01     | Shell  | Supported     |                                            |
| C00 – C08   | C      | Supported     | Full compilation + functional tests        |
| C09 – C11   | C      | In Progress   |                                            |
| C12 – C13   | C      | In Progress   | Valgrind configured, tests WIP             |
| Reloaded    | Shell  | Supported     | Auto-detects `~/reloaded`                  |
| Libft       | C      | Supported     | Common Core milestone                      |

---

## How It Works

### Context-Aware Auto-Detection

If you run `mulineti` from inside a recognized folder (e.g. `C02`, `Shell01`), it launches directly — no menu needed.

```
C02/  →  runs C02 tests automatically
Shell01/  →  runs Shell01 tests automatically
```

From any other directory, the interactive menu opens:

```
╔══════════════════════════════════════════════════════════════╗
║              🌊  MULINETI - COMMAND CENTER                   ║
╚══════════════════════════════════════════════════════════════╝
1. Piscina (Auto-Detect)
2. Piscine Reloaded
3. Common Core (Milestones)
0. Exit
```

### Sandbox Architecture

Each run copies the engine into an isolated `mulineti_tmp/` folder, executes tests there, then deletes the sandbox. Your working directory is never touched.

### Piscine Reloaded Integration

When running the Reloaded module, Mulineti looks for your work at `~/reloaded`. If the folder doesn't exist, it falls back to the parent directory (standard Piscine behavior).

### Scoring Logic

Results follow 42's chain-failure model:

| Status       | Meaning                                          |
| :----------: | :----------------------------------------------- |
| `PASS (OK)`  | Exercise passed and score counts                 |
| `Locked`     | Logic correct, but a prior failure blocked it    |
| `NORM ERROR` | Norminette violation                             |
| `BUILD ERROR`| Missing file or compilation failure              |
| `SKIPPED`    | Requires a Git environment (Shell00 ex05/ex06)   |
| `KO`         | Functional test failed                           |

---

## Getting Started

> **Warning:** Mulineti is not 100% accurate. Tests may not cover every edge case that the real moulinette checks. Use it as a pre-submission sanity check, not as a guarantee.

### 1. Clone to your home directory

```bash
git clone https://github.com/khairulhaaziq/mini-moulinette.git ~/mulineti
```

### 2. Create an alias

**zsh:**
```zsh
echo "alias mulineti='~/mulineti/mulineti.sh'" >> ~/.zshrc && source ~/.zshrc
```

**bash:**
```bash
echo "alias mulineti='~/mulineti/mulineti.sh'" >> ~/.bashrc && source ~/.bashrc
```

### 3. Run from your exercise directory

```bash
cd ~/C02
mulineti
```

Or from anywhere using the menu:

```bash
mulineti
```

### Updating

```bash
cd ~/mulineti && git pull
```

---

## Logs

Each run saves a clean log (no ANSI codes) to:

```
mulineti/logs/<module>.txt
```

Example: `logs/C02.txt`, `logs/Reloaded.txt`, `logs/Shell01.txt`

---

## Debugging

### Code doesn't compile
- Check that your function is named exactly as specified
- Remove any `main()` if the exercise doesn't ask for one
- Check your `#include` headers

### Segmentation fault
Test cases live under:

```bash
~/mulineti/mulineti/tests/<module>/<exercise>/
```

For C modules, tests are written as arrays of `t_test` structs. For Shell modules, they are `run_test.sh` scripts. You can inspect and extend them.

---

## Contributing

- **Bug reports / test corrections:** Open an issue or reach out on Discord
- **New test cases:** Submit a pull request — follow the existing structure under `mulineti/tests/`
- **New modules:** Open an issue to discuss coverage before implementing

---

## License

MIT. Copyright 2023 [Khairul Haaziq](https://github.com/khairulhaaziq).
