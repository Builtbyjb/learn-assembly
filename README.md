# Learning Assembly
Learning Assembly by building a simple calculator

## Usage
The following instructions are for a MacOs Apple Silicon Operating System.

Clone the repo
```sh
git clone https://github.com/Builtbyjb/learn-assembly.git
```

Install MacOs command line tools
```sh
xcode-select --install
```

Compile the binary
```sh
gcc calculator.s -o calculator
```

Run binary
> [!NOTE]
> Floating point operations are not supported.
```sh
./calculator 6 + 7
```
