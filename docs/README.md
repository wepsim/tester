# WepSIM Tester for submissions

### Initial steps

1. First, you need to download the project (download the .zip file or "git clone" it):
```console
   wget https://github.com/wepsim/tester/archive/refs/heads/main.zip
   unzip tester-main.zip
   cd tester-main/
```

2. Then, you need to download all laboratories of each teaching group and save the associated .zip file the ```submissions``` directory.
```console
   ls submissions
```

3. Finally, complete the solutions (labeled as TODO in the test directory files)
```console
   ls test
```


### PHASE 1: To check one group

1. First, you need to spin up the container with:
```console
   ./ws.sh start
```

2. To unzip the submitted files in p2-90.zip for the group 90 please use:
```console
   ./s10_unzip.sh  p2-90.zip
```

3. To prepare the execution output to compare with:
```console
   ./s10_tests.sh      tests/tests.in   
```

4. To check only the 90 group:
```console
   ./s20_check.sh      tests/tests.in   p2-90.in
```

5. Finally, you can spin down the container:
```console
   ./ws.sh stop
```

### PHASE 2: To check again one group and make the ajustments to the submissions

1. First, you need to spin up the container with:
```console
   ./ws.sh start
```

2. For each submitted work named <xxxxx_yyyyy> that needs some modification please first backup the original files in the *ORIGINAL* subdirectory:
```console
   mkdir -p p2-90/<xxxxx_yyyyy>/ORIGINAL
   cp    -a p2-90/<xxxxx_yyyyy>/*   p2-90/<xxxxx_yyyyy>/ORIGINAL
```
   * For example:
     * If file names are not OK (p2-report.pdf, ej2_microcode.txt.txt, etc.)
     * If fetch has to be removed from the submitted microcode.
     * Etc.
   * Normally the adjustments involve penalties for not following what is requested in the statement.

3.a To check again the 90 group:
```console
   ./s10_tests.sh      tests/tests.in   
   ./s20_check.sh      tests/tests.in   p2-90.in
```

3.b To check again several groups:
```console
   ./s20_check.sh      tests/tests.in   p2-80.in
   ./s20_check.sh      tests/tests.in   p2-81.in
   ./s20_check.sh      tests/tests.in   p2-82.in
   ./s20_check.sh      tests/tests.in   p2-83.in
```

3.c To check a sublist please use:
```console
   mv p2-90.in p2-90-original.in
   grep 100xxx p2-90-original.in > p2-90.in
```

4. Finally, you can spin down the container:
```console
   ./ws.sh stop
```

