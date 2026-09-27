class Mobil {
  String _model;
  String _tipe;
  String _warna;
  String _kategori;
  int _tahunpembuatan;
  String _gambar;
  int _harga;

  Mobil({
    required String model,
    required String tipe,
    required String warna,
    required String kategori,
    required int tahunpembuatan,
    required String gambar,
    required int harga,
  })  : _model = model,
        _tipe = tipe,
        _warna = warna,
        _kategori = kategori,
        _tahunpembuatan = tahunpembuatan,
        _gambar = gambar,
        _harga = harga;


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

  int get harga => _harga;
  set harga(int value) => _harga = value;
}