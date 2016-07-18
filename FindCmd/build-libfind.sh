#!/bin/sh
build_root=findutils-4.6.0
target_lib_name=libftsfind.a

cflags_iphoneos_32="-arch armv7 -arch armv7s"
cflags_iphoneos_64="-arch arm64"
cflags_iphonesimulator_32="-arch i386"
cflags_iphonesimulator_64="-arch x86_64"
cppflags_iphoneos="-D __arm__=1"
cppflags_iphonesimulator=""

cd ${build_root}

for sdk_name in iphoneos iphonesimulator
do
    for arch_bit in 32 64
    do
	make distclean
	export SDKROOT="$(xcrun --sdk ${sdk_name} --show-sdk-path)"
	export CC="$(xcrun --sdk ${sdk_name} -f clang)"
	export CPP="$(xcrun --sdk ${sdk_name} -f cc) -E $(eval echo \$cppflags_${sdk_name})"
	export CFLAGS="-O2 -isysroot $(xcrun --sdk ${sdk_name} --show-sdk-path) -fembed-bitcode -miphoneos-version-min=7.0 $(eval echo \$cflags_${sdk_name}_${arch_bit})"
	export RANLIB="$(xcrun --sdk ${sdk_name} -f ranlib)"
	export LIBTOOL="$(xcrun --sdk ${sdk_name} -f libtool)"
	./configure --host=arm-apple-darwin --prefix="$(pwd)/build-${sdk_name}-${arch_bit}"
	make -j4
	make install
    done
done

for sdk_name in iphoneos iphonesimulator
do
    for arch_bit in 32 64
    do
	ls -la "$(pwd)/build-${sdk_name}-${arch_bit}/lib/${target_lib_name}"
    done
done

xcrun lipo -create "$(pwd)"/build-{iphoneos,iphonesimulator}-{32,64}/lib/${target_lib_name} -output ../${target_lib_name}
xcrun lipo -info ../${target_lib_name}
file ../${target_lib_name}
