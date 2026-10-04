import 'package:get/get.dart';
enum AccessLevel { guest, registered, complete }

class AuthController extends GetxController {
  final Rx<AccessLevel> accessLevel = AccessLevel.guest.obs;

  final RxString nama = ''.obs;
  final RxString email = ''.obs;

  final RxString nik = ''.obs;
  final RxString noKK = ''.obs;
  final RxString noHp = ''.obs;
  final RxString alamat = ''.obs;

  bool get isGuest => accessLevel.value == AccessLevel.guest;

  bool get isRegistered =>
      accessLevel.value.index >= AccessLevel.registered.index;

  bool get isComplete => accessLevel.value == AccessLevel.complete;

  void registerAccount({
    required String namaUser,
    required String emailUser,
  }) {
    nama.value = namaUser;
    email.value = emailUser;
    accessLevel.value = AccessLevel.registered;
  }

  void completeProfile({
    required String nikUser,
    required String noKKUser,
    required String noHpUser,
    required String alamatUser,
  }) {
    nik.value = nikUser;
    noKK.value = noKKUser;
    noHp.value = noHpUser;
    alamat.value = alamatUser;
    accessLevel.value = AccessLevel.complete;
  }

  void logout() {
    accessLevel.value = AccessLevel.guest;
    nama.value = '';
    email.value = '';
    nik.value = '';
    noKK.value = '';
    noHp.value = '';
    alamat.value = '';
  }
}