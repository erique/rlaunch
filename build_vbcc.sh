#!/bin/bash

set -e

check_cmd () { hash $1 2>/dev/null && { echo >&2 "'$1' found"; } || { echo >&2 "'$1' is required, but not found."; exit 1; }; }

check_cmd wget
check_cmd 7z
check_cmd patch

export VBCC=$PWD/vbcc

rm -rf $VBCC
mkdir -p $VBCC
pushd $VBCC

mkdir -p bin
mkdir -p config
mkdir -p targets

echo -e "\033[1;33m****** CONFIG ******\033[0m"

cat << 'EOF' | sed -e s:%%VBCC%%:$VBCC:g | sed -e 's:/\([a-z]\)/:\1\:/:g' > config/vc.config
-cc=%%VBCC%%/bin/vbccm68k -quiet -hunkdebug %s -o= %s %s -O=%ld -I"%%VBCC%%/targets/m68k-amigaos/include" -I"%%VBCC%%/targets/m68k-amigaos/ndkinclude" -I"%%VBCC%%/targets/m68k-amigaos/netinclude"
-ccv=%%VBCC%%/bin/vbccm68k       -hunkdebug %s -o= %s %s -O=%ld -I"%%VBCC%%/targets/m68k-amigaos/include" -I"%%VBCC%%/targets/m68k-amigaos/ndkinclude" -I"%%VBCC%%/targets/m68k-amigaos/netinclude"
-as=%%VBCC%%/bin/vasmm68k_mot -quiet -Fhunk -phxass -opt-fconst -nowarn=62 %s -o %s
-asv=%%VBCC%%/bin/vasmm68k_mot       -Fhunk -phxass -opt-fconst -nowarn=62 %s -o %s
-rm=rm %s
-rmv=rm %s
-ld=%%VBCC%%/bin/vlink  -bamigahunk -x -Bstatic -Cvbcc -nostdlib "%%VBCC%%/targets/m68k-amigaos/lib/startup.o"    %s %s -L"%%VBCC%%/targets/m68k-amigaos/lib" -lvc -lamiga -o %s
-l2=%%VBCC%%/bin/vlink  -bamigahunk -x -Bstatic -Cvbcc -nostdlib                                                  %s %s -L"%%VBCC%%/targets/m68k-amigaos/lib"              -o %s
-ldv=%%VBCC%%/bin/vlink -bamigahunk -t -x -Bstatic -Cvbcc -nostdlib "%%VBCC%%/targets/m68k-amigaos/lib/startup.o" %s %s -L"%%VBCC%%/targets/m68k-amigaos/lib" -lvc         -o %s
-l2v=%%VBCC%%/bin/vlink -bamigahunk -t -x -Bstatic -Cvbcc -nostdlib                                               %s %s -L"%%VBCC%%/targets/m68k-amigaos/lib"              -o %s
-ldnodb=-s -Rshort
-ul=-l%s
-cf=-F%s
-ml=500
EOF
cp config/vc.config config/vc.cfg
cat config/vc.cfg

echo -e "\033[1;33m****** VBCC ******\033[0m"

wget https://github.com/erique/vbcc_vasm_vlink/raw/master/vbcc.tar.gz
tar xzf vbcc.tar.gz
patch -p 0 << 'EOF'
diff -rupN vbcc/datatypes/dtgen.c vbcc.patch/datatypes/dtgen.c
--- vbcc/datatypes/dtgen.c	2013-04-24 00:45:50 +0200
+++ vbcc.patch/datatypes/dtgen.c	2020-01-01 21:11:42 +0100
@@ -133,8 +133,7 @@ int askyn(char *def)
   do{
     printf("Type y or n [%s]: ",def);
     fflush(stdout);
-    fgets(in,sizeof(in),stdin);
-    if(*in=='\n') strcpy(in,def);
+    strcpy(in,def);
   }while(*in!='y'&&*in!='n');
   return *in=='y';
 }
@@ -144,9 +143,7 @@ char *asktype(char *def)
   char *in=mymalloc(128);
   printf("Enter that type[%s]: ",def);
   fflush(stdout);
-  fgets(in,127,stdin);
-  if(in[strlen(in)-1]=='\n') in[strlen(in)-1]=0;
-  if(!*in) strcpy(in,def);
+  strcpy(in,def);
   return in;
 }
EOF
cd vbcc && mkdir -p bin && make TARGET=m68k -j 4 && cp bin/vc ../bin && cp bin/vbccm68k ../bin && cd -
rm -rf vbcc vbcc.tar.gz

echo -e "\033[1;33m****** VBCC/68K ******\033[0m"

wget https://github.com/erique/vbcc_vasm_vlink/raw/master/vbcc_target_m68k-amigaos.lha
7z x vbcc_target_m68k-amigaos.lha
cd vbcc_target_m68k-amigaos && mv targets/m68k-amigaos ../targets/m68k-amigaos && cd -
rm -rf vbcc_target_m68k-amigaos*

echo -e "\033[1;33m****** VLINK ******\033[0m"

wget https://github.com/erique/vbcc_vasm_vlink/raw/master/vlink.tar.gz
tar xzf vlink.tar.gz
cd vlink && make -j 4 && cp vlink ../bin && cd -
rm -rf vlink vlink.tar.gz

echo -e "\033[1;33m****** VASM ******\033[0m"

wget https://github.com/erique/vbcc_vasm_vlink/raw/master/vasm.tar.gz
tar xzf vasm.tar.gz
cd vasm && make CPU=m68k SYNTAX=mot -j 4 && cp vasmm68k_mot ../bin && cd -
rm -rf vasm vasm.tar.gz

echo -e "\033[1;33m****** NDK ******\033[0m"

wget https://aminet.net/dev/misc/NDK3.2.lha
7z x -y NDK3.2.lha -oNDK
cd NDK && mv Include_H ../targets/m68k-amigaos/ndkinclude && cd -
rm -rf NDK NDK3.2.lha

echo -e "\033[1;33m****** AmiTCP SDK ******\033[0m"

wget http://aminet.net/comm/tcp/AmiTCP-SDK-4.3.lha
7z x -y AmiTCP-SDK-4.3.lha AmiTCP-SDK-4.3
cd AmiTCP-SDK-4.3 && mv netinclude ../targets/m68k-amigaos/netinclude && cd -
rm -rf AmiTCP-SDK-4.3 AmiTCP-SDK-4.3.lha

echo -e "\033[1;33m****** DONE ******\033[0m"

popd
