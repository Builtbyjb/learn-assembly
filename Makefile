dev:
	as calculator.s -o calculator.o && \
	ld calculator.o -o calculator -l System -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _main -arch arm64
