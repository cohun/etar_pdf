import 'dart:io';
import 'package:etar_products_upload/models/inspection_model.dart';
import 'package:etar_products_upload/models/parts_model.dart';
import 'package:etar_products_upload/models/product_model.dart';
import 'package:etar_products_upload/src/services/database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io' show Directory;


class StartPdf extends StatefulWidget {
  final String company;
  final Database database;
  final String productId;
  final String what;
  final String whatEnglish;
  final String nr;
  final Color color;

  const StartPdf({Key key,
    this.company,
    this.database,
    this.productId,
    this.what,
    this.nr,
    this.whatEnglish,
    this.color})
      : super(key: key);

  @override
  _StartPdfState createState() => _StartPdfState();
}

class _StartPdfState extends State<StartPdf> {
  String _address;
  List<PartModel> partsList = [];
  List<List<String>> partTable = [];

  ProductModel _product;
  String type;
  String length;
  String description;
  String site;
  String person;
  String capacity;
  String manufacturer;

  InspectionModel _event;
  String nr;
  String doer;
  String comment;
  String result;
  String date;
  String nextDate;
  String eventType;

  final pdf = pw.Document();

  Future<pw.PageTheme> _myPageTheme() async {
    return pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(32),
      theme: pw.ThemeData.withFont(
        base: pw.Font.ttf(
            await rootBundle.load('lib/assets/fonts/OpenSans-Regular.ttf')),
        bold: pw.Font.ttf(
            await rootBundle.load('lib/assets/fonts/OpenSans-Bold.ttf')),
      ),
    );
  }

  String fullPath = '';

  writeOnPdf() async {
    final pw.PageTheme pageTheme = await _myPageTheme();

    final _logo = pw.MemoryImage(
      (await rootBundle.load('lib/assets/images/Logo.png')).buffer.asUint8List(),
    );
    final _etar = pw.MemoryImage(
      (await rootBundle.load('lib/assets/images/ETAR1@2x.png')).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.Page(
        pageTheme: pageTheme,
        build: (pw.Context context) =>
            pw.Row(
              children: <pw.Widget>[
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.only(left: 30, bottom: 20),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: <pw.Widget>[
                        //******FIRST ROW************************************
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            //****************LOGO***************************
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Container(
                                  height: 32,
                                  child: _logo != null
                                      ? pw.Image(_logo)
                                      : pw.PdfLogo(),
                                ),
                                pw.Text('Emel??g??p Szakszolg??lat'),
                                pw.Text('1119 Budapest'),
                                pw.Text('Kelenv??lgyi htsr. 5'),
                              ],
                            ),
                            //*********************************************
                            pw.Column(
                              children: [
                                pw.Container(
                                  height: 32,
                                  child: _etar != null
                                      ? pw.Image(_etar)
                                      : pw.PdfLogo(),
                                ),
                                widget.whatEnglish == 'operationEnd' ?
                                pw.Text('${widget.what}',
                                  textScaleFactor: 1.3,
                                  style: pw.Theme
                                      .of(context)
                                      .defaultTextStyle
                                      .copyWith(
                                      fontWeight: pw.FontWeight.bold),)
                                    : pw.Text(
                                  '${eventType}i',
                                  textScaleFactor: 1.5,
                                  style: pw.Theme
                                      .of(context)
                                      .defaultTextStyle
                                      .copyWith(fontWeight: pw.FontWeight.bold),
                                ),
                                pw.Text(
                                  'Jegyz??k??nyv',
                                  textScaleFactor: 1.5,
                                  style: pw.Theme
                                      .of(context)
                                      .defaultTextStyle
                                      .copyWith(fontWeight: pw.FontWeight.bold),
                                ),
                              ],
                            ),
                            pw.Column(
                              children: [
                                pw.Text('Sorsz??m:',
                                    textScaleFactor: 1.2,
                                    style: pw.Theme
                                        .of(context)
                                        .defaultTextStyle
                                        .copyWith(
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColor(.4, .3, .2))),
                                pw.Text('$nr',
                                    textScaleFactor: 1.2,
                                    style: pw.Theme
                                        .of(context)
                                        .defaultTextStyle
                                        .copyWith(
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColor(.4, .3, .2))),
                              ],
                            ),
                          ],
                        ),
                        //****************************************************
                        pw.Container(
                          alignment: pw.Alignment.centerRight,
                          margin: const pw.EdgeInsets.only(
                              bottom: 3.0 * PdfPageFormat.mm),
                          padding: const pw.EdgeInsets.only(
                              bottom: 3.0 * PdfPageFormat.mm),


                          decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                  bottom: pw.BorderSide(
                                      width: 0.5,
                                      color: PdfColors.grey))),
                          child: pw.Container(
                            height: 0,
                          ),
                        ),
                        //****************************************************
                        widget.whatEnglish == 'inspections'
                            ? pw.Text(
                          'Igazol??s emel??g??pek id??szakos vizsg??lat??nak elv??gz??s??r??l'
                              ' EBSZ 7.2.1 pontja szerinti. '
                              'Vizsg??latok az MSZ 9721-1 szabv??nysorozatban megadottak szerint t??rt??ntek.',
                          textScaleFactor: 0.8,
                        )
                            : widget.whatEnglish == 'operationStart'
                            ? pw.Text(
                          'Els?? ??zembehelyez??st megel??z?? ??zemszer?? alkalmass??g- ??s '
                              'm??k??d??k??pess??g ellen??rz??s??nek dokument??l??sa MSZ 6726-1:2011 szerint.',
                          textScaleFactor: 0.8,
                        )
                            : widget.whatEnglish == 'repairs'
                            ? pw.Text(
                          'Nyilatkozat az emel??g??p biztons??gos, ??zemk??sz ??llapot??nak helyre??ll??t??s??r??l',
                          textScaleFactor: 0.8,
                        )
                            : widget.whatEnglish == 'maintenances'
                            ? pw.Text(
                          'Igazol??s az emel??g??p haszn??lati utas??t??sa el????r??sai szerinti ellen??rz??sek, '
                              'be??ll??t??sok, ken??sek elv??gz??s??r??l',
                          textScaleFactor: 0.8,
                        )
                            : widget.whatEnglish == 'operationEnd'
                            ? pw.Text(
                          'Nevezett emel??g??p haszn??latb??l t??rt??n?? kivon??sa megt??rt??nt, az itt megadott '
                              'id??pont ut??n haszn??lata tilos',
                          textScaleFactor: 0.8,
                        )
                            : pw.Container(height: 0),
                        _buildUserTable(context),
                        _buildProductTable(context),
                        _buildEventTable(context),
                        _buildDoerTable(context),
                        widget.whatEnglish == 'repairs'
                            ? _buildParts(context)
                            : pw.Container(height: 0),
                      ],
                    ),
                  ),
                ),
              ]
              ,
            )
        ,
      )
      ,
    );

    return pdf.save();
  }

  //***************************************************************************
  pw.Widget _buildUserTable(pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
        pw.Text('??zemeltet??:',
            textScaleFactor: 1.2,
            style: pw.Theme
                .of(context)
                .defaultTextStyle
                .copyWith(
                fontWeight: pw.FontWeight.bold, color: PdfColor(.4, .3, .2))),
        pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
        pw.Table.fromTextArray(
          context: context,
          data: <List<String>>[
            <String>['C??gn??v:', 'C??m:'],
            <String>['${widget.company}', '$_address'],
          ],
        ),
        pw.Table.fromTextArray(
          context: context,
          data: <List<String>>[
            <String>['??zemeltet??s helysz??ne:', 'Felhaszn??l?? neve:'],
            <String>['$site', '$person'],
          ],
        ),
      ],
    );
  }

  pw.Widget _buildProductTable(pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
        pw.Text('Term??k:',
            textScaleFactor: 1.2,
            style: pw.Theme
                .of(context)
                .defaultTextStyle
                .copyWith(
                fontWeight: pw.FontWeight.bold, color: PdfColor(.4, .3, .2))),
        pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
        pw.Table.fromTextArray(
          context: context,
          data: <List<String>>[
            <String>['T??pus:', 'Hossz:', 'Megnevez??s:'],
            <String>['$type', '$length', '$description'],
          ],
        ),
        pw.Table.fromTextArray(
          context: context,
          data: <List<String>>[
            <String>['Gy??risz??m:', 'Teherb??r??s:', 'Gy??rt??:'],
            <String>['${widget.productId}', '$capacity', '$manufacturer'],
          ],
        ),
      ],
    );
  }

  pw.Widget _buildEventTable(pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
        pw.Text('$eventType eredm??nye:',
            textScaleFactor: 1.2,
            style: pw.Theme
                .of(context)
                .defaultTextStyle
                .copyWith(
                fontWeight: pw.FontWeight.bold, color: PdfColor(.4, .3, .2))),
        pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
        pw.Table.fromTextArray(
          context: context,
          data: <List<String>>[
            <String>['$result'],
          ],
        ),
        pw.Padding(padding: const pw.EdgeInsets.only(top: 30)),
        pw.Table.fromTextArray(
          context: context,
          data: <List<String>>[
            <String>['${widget.what} id??pontja:', 'K??vetkez?? id??pont:'],
            <String>['$date', '$nextDate'],
          ],
        ),
        pw.Table.fromTextArray(
          context: context,
          data: <List<String>>[
            <String>['Megjegyz??s:'],
            <String>['$comment'],
          ],
        ),
      ],
    );
  }

  pw.Widget _buildDoerTable(pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
        pw.Text('Az elv??gzett munka szakszer??s??g??t igazolja:',
            textScaleFactor: 1.2,
            style: pw.Theme
                .of(context)
                .defaultTextStyle
                .copyWith(
                fontWeight: pw.FontWeight.bold, color: PdfColor(.4, .3, .2))),
        pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
        pw.Table.fromTextArray(
          context: context,
          data: <List<String>>[
            <String>['$doer'],
          ],
        ),
        pw.Text('Id??pecs??t: ${DateTime.now()}'),
        pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
        pw.Text(
          'ETAR?? adatkezel??si rendszer, az egyedi sorsz??m kioszt??ssal biztos??tja a jegyz??k??nyv hiteless??g??t,'
              ' al????r??s n??lk??l.',
          style: pw.TextStyle(),
        ),
      ],
    );
  }

  pw.Widget _buildParts(pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
        pw.Text('Felhaszn??lt anyagok:',
            textScaleFactor: 1.2,
            style: pw.Theme
                .of(context)
                .defaultTextStyle
                .copyWith(
                fontWeight: pw.FontWeight.bold, color: PdfColor(.4, .3, .2))),
        pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
        pw.Container(
          width: 580,
          child: pw.Text('$partTable'),
        ),
      ],
    );
  }

  //***************************************************************************

  Future<void> _saveAsFile() async {
    // final Directory appDocDir = await getApplicationDocumentsDirectory();
    // final String appDocPath = appDocDir.path;
    // final File file = File(appDocPath + '/' + 'document.pdf');
    // print('Save as file ${file.path} ...');
    // await file.writeAsBytes((await generateDocument(PdfPageFormat.a4)).save());
    // Navigator.push<dynamic>(
    //   context,
    //   MaterialPageRoute<dynamic>(
    //       builder: (BuildContext context) => PdfViewer(file: file)),
    // );
  }




  Future savePdf() async {
    // if(kIsWeb)
    //   print("It's web");
    //
    // else if(Platform.isAndroid){
    //   print("it's Android"); }
    // // Directory documentDirectory = await getApplicationDocumentsDirectory();
    //
    // Directory tempDirectory = await getTemporaryDirectory();
    //
    // // String documentPath = documentDirectory.path;
    // String tempPath = tempDirectory.path;
    //
    // File file = File('$tempPath/cert.pdf');
    // file.writeAsBytesSync(await pdf.save());
    //
    // File tempFile = File('$tempPath/jkv_${widget.productId}.pdf');
    // tempFile.writeAsBytesSync(await pdf.save());
  }

  @override
  void initState() {
    super.initState();
    getData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('PDF'),
        backgroundColor: widget.color,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Center(child: Text('??zemeltet??')),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('C??gn??v: '),
                            Text(
                              '${widget.company}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('C??m: '),
                            Text(
                              '$_address',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Hely: '),
                            Text(
                              '$site',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Szem??ly: '),
                            Text(
                              '$person',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Center(child: Text('Term??k')),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Megnevez??s: '),
                            Text(
                              '$description',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('T??pus: '),
                            Text(
                              '$type',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Hossz: '),
                            Text(
                              '$length',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Teherb??r??s: '),
                            Text(
                              '$capacity',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Gy??rt??: '),
                            Text(
                              '$manufacturer',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Gy??risz??m: '),
                            Text(
                              '${widget.productId}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Center(child: Text('${widget.what}')),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Sorsz??m: '),
                            Text(
                              '${widget.nr}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Elv??gz??s id??pontja: '),
                            Text(
                              '$date',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('K??vetkez?? id??pont: '),
                            Text(
                              '$nextDate',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Munk??t v??gezte: '),
                            Text(
                              '$doer',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Eredm??ny: '),
                            Text(
                              '$result',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          //**********************************************************
          widget.whatEnglish == 'repairs'
              ? Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SingleChildScrollView(
                    child: ListTile(
                      title:
                      Center(child: Text('Felhaszn??lt alkatr??szek')),
                      subtitle: create(),
                    ),
                  ),
                ],
              ),
            ),
          )
              : Container(
            height: 0,
          ),
          //**********************************************************
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: widget.color,
        onPressed: () {
     },
        child: Icon(
          Icons.picture_as_pdf_rounded,
          color: Color(0xffffc108),
        ),
      ),
    );
  }

  //************************************************************************
  Future<void> getAddress() async {
    final counters =
    await widget.database
        .companyIdStream(widget.company)
        .first;
    final allAddress = counters.map((e) => e.address).toList();
    setState(() {
      _address = allAddress[0];
    });
  }

  getData() async {
    if(widget.nr != '') {
      widget.whatEnglish == 'operationEnd' ?
      setEvent() :
      await retrieveEvent();
    }
    await retrieveProduct();
    await getAddress();
  }

  //************************************************************************
  setEvent() {
    doer = widget.nr;
    nr = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(2, 8) +
        '/${DateTime.now().year}';
    date = DateTime.now().toIso8601String().substring(0, 10);
    eventType = 'Elj??r??s';
    result = 'Leselejtezve';
    comment = '';
    nextDate = 'nincs';
  }


  //**********************************************************************

  Future<void> retrieveEvent() async {
    var _nr = widget.nr.substring(0, 6);
    try {
      await widget.database
          .getEvent(widget.company, _nr, widget.whatEnglish)
          .then((value) => _event = value);
      setState(() {
        if (_event != null) {
          nr = _event.nr;
          date = _event.date;
          nextDate = _event.nextDate;
          result = _event.result;
          doer = _event.doer;
          comment = _event.comment;
          eventType = _event.type;
        } else {
          print('null is the result');
        }
      });
    } on PlatformException catch (e) {
      AlertDialog(
        title: Text('M??velet sikertelen'),);
    }
  }

  Future<void> retrieveProduct() async {
    try {
      await widget.database
          .getProduct(widget.company, widget.productId)
          .then((value) => _product = value);
      setState(() {
        if (_product != null) {
          type = _product.type;
          description = _product.description;
          length = _product.length;
          capacity = _product.capacity;
          manufacturer = _product.manufacturer;
          site = _product.site;
          person = _product.person;
        } else {
          print('null is the result');
        }
      });
    } on PlatformException catch (e) {
      AlertDialog(
        title: Text('M??velet sikertelen'),);
    }
  }

  //******************************************************************
  Widget create({BuildContext context}) {
    return StreamBuilder<List<PartModel>>(
      stream:
      widget.database.oneDateRepairPartsStream(widget.company, widget.nr),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<PartModel> parts = snapshot.data;

          if (parts.isNotEmpty) {
            partsList = [];
            partTable = [];
            for (var part in parts) {
              partsList.add(part);
              partTable.add([part.pieces, part.unit, part.type]);
            }

            return partList(context);
          } else {
            partsList = [];
            return Center(
              child: Text(
                'Nem volt alkatr??szfelhaszn??l??s!',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            );
          }
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Hiba t??rt??nt'),
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget partList(BuildContext context) {
    return Container(
      height: MediaQuery
          .of(context)
          .size
          .height * 0.2,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: partsList.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${partsList[index].pieces}  ${partsList[index].unit}  '),
                  Text(
                    '${partsList[index].type}  ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
