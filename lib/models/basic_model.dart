class Mobil {
  String _model;
  String _tipe;
  String _warna;
  String _kategori;
  int _tahunpembuatan;
  String _gambar;
  String? _gambarDetail;
  int _harga;
  String _transmisi;
  String _bahanBakar;
  int _kapasitasPenumpang;
  List<String> _fiturUnggulan;
  String _deskripsi;

  Mobil({
    required String model,
    required String tipe,
    required String warna,
    required String kategori,
    required int tahunpembuatan,
    required String gambar,
    String? gambarDetail,
    required int harga,
    required String transmisi,
    required String bahanBakar,
    required int kapasitasPenumpang,
    required List<String> fiturUnggulan,
    required String deskripsi,
  })  : _model = model,
        _tipe = tipe,
        _warna = warna,
        _kategori = kategori,
        _tahunpembuatan = tahunpembuatan,
        _gambar = gambar,
        _gambarDetail = gambarDetail,
        _harga = harga,
        _transmisi = transmisi,
        _bahanBakar = bahanBakar,
        _kapasitasPenumpang = kapasitasPenumpang,
        _fiturUnggulan = fiturUnggulan,
        _deskripsi = deskripsi;

  String get model => _model;
  set model(String value) => _model = value;

  String get tipe => _tipe;
  set tipe(String value) => _tipe = value;

  String get warna => _warna;
  set warna(String value) => _warna = value;

  String get kategori => _kategori;
  set kategori(String value) => _kategori = value;

  int get tahunpembuatan => _tahunpembuatan;
  set tahunpembuatan(int value) => _tahunpembuatan = value;

  String get gambar => _gambar;
  set gambar(String value) => _gambar = value;

  String get gambarUntukDetail => _gambarDetail ?? _gambar;
  String? get gambarDetailRaw => _gambarDetail;
  set gambarDetail(String? value) => _gambarDetail = value;

  int get harga => _harga;
  set harga(int value) => _harga = value;

  String get transmisi => _transmisi;
  set transmisi(String value) => _transmisi = value;

  String get bahanBakar => _bahanBakar;
  set bahanBakar(String value) => _bahanBakar = value;

  int get kapasitasPenumpang => _kapasitasPenumpang;
  set kapasitasPenumpang(int value) => _kapasitasPenumpang = value;

  List<String> get fiturUnggulan => _fiturUnggulan;
  set fiturUnggulan(List<String> value) => _fiturUnggulan = value;

  String get deskripsi => _deskripsi;
  set deskripsi(String value) => _deskripsi = value;
}