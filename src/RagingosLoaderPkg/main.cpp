extern "C" {

#include  <Uefi.h>
#include  <Library/UefiLib.h>

EFI_STATUS EFIAPI UefiMain(EFI_HANDLE image_handle, EFI_SYSTEM_TABLE *system_table) {
    Print(reinterpret_cast<const CHAR16*>(L"Hello, RAGINGOS World!!!!\n"));
    while (1);
    return EFI_SUCCESS;
}

}
