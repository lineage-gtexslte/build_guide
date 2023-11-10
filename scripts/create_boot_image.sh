mkbootfs /home/android/lineage/out/target/product/gtexslte/root | minigzip > /tmp/boot.img-ramdisk-new.gz && \
degas-mkbootimg -o /home/android/lineage/out/target/product/gtexslte/boot.img --base 0 --pagesize 2048 \
  --kernel /home/android/lineage/kernel/samsung/gtexslte/arch/arm/boot/zImage --cmdline "console=ttyS1,115200n8" \
  --ramdisk /tmp/boot.img-ramdisk-new.gz --dt /home/android/lineage/kernel/samsung/gtexslte/dt.img \
  --signature /home/android/lineage/device/samsung/gtexslte/seandroid.img