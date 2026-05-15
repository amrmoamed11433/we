// =============================================================================
// AppLocalizations
// =============================================================================
// This file is hand-written so the project compiles immediately without
// running `flutter gen-l10n`. The Flutter build system will normally regenerate
// it from the .arb files in this folder, but this manual copy keeps strings
// aligned with app_en.arb / app_ar.arb and works out of the box.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    _AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  bool get isArabic => locale.languageCode == 'ar';

  // ---------------------------------------------------------------------------
  // Strings
  // ---------------------------------------------------------------------------

  String _s(String en, String ar) => isArabic ? ar : en;

  String get appTitle => _s('WE Packages Manager', 'إدارة باقات WE');

  String get navDashboard => _s('Dashboard', 'الرئيسية');
  String get navGroups => _s('Groups', 'الجروبات');
  String get navHistory => _s('History', 'السجل');
  String get navSettings => _s('Settings', 'الإعدادات');

  String get dashboardTitle => _s('Dashboard', 'الرئيسية');
  String get totalCollected => _s('Total Collected', 'إجمالي المحصل');
  String get totalPending => _s('Total Pending', 'المعلق');
  String get totalExpectedSales => _s('Expected Sales', 'المبيعات المتوقعة');
  String get totalCompanyCosts => _s('Company Costs', 'تكلفة الشركة');
  String get netProfit => _s('Net Profit', 'صافي الربح');
  String get paidCustomers => _s('Paid', 'مدفوع');
  String get unpaidCustomers => _s('Unpaid', 'غير مدفوع');
  String get currentCycles => _s('Current Cycles', 'الدورات الحالية');

  String get groupsTitle => _s('Groups', 'الجروبات');
  String get group1 => _s('Group 1', 'الجروب 1');
  String get group2 => _s('Group 2', 'الجروب 2');
  String get group3 => _s('Group 3', 'الجروب 3');
  String get groupName => _s('Group Name', 'اسم الجروب');
  String get renewalDay => _s('Renewal Day', 'يوم التجديد');
  String get renewalDay1 => _s('Day 1', 'يوم 1');
  String get renewalDay16 => _s('Day 16', 'يوم 16');
  String get companyCost => _s('Company Cost', 'تكلفة الشركة');
  String get currentCompanyCost =>
      _s('Current Company Cost', 'تكلفة الشركة الحالية');
  String get customersCount => _s('Customers', 'عدد العملاء');
  String get editGroup => _s('Edit Group', 'تعديل الجروب');
  String get saveGroup => _s('Save Group', 'حفظ الجروب');

  String get groupDetails => _s('Group Details', 'تفاصيل الجروب');
  String get cycleStartDate => _s('Cycle Start', 'بداية الدورة');
  String get cycleEndDate => _s('Cycle End', 'نهاية الدورة');
  String get customerList => _s('Customers', 'العملاء');
  String get addCustomer => _s('Add Customer', 'إضافة عميل');
  String get editCustomer => _s('Edit Customer', 'تعديل العميل');
  String get deleteCustomer => _s('Delete Customer', 'حذف العميل');
  String get markAsPaid => _s('Mark as Paid', 'تم الدفع');
  String get markAsUnpaid => _s('Mark as Unpaid', 'إلغاء الدفع');
  String get paid => _s('Paid', 'مدفوع');
  String get unpaid => _s('Unpaid', 'غير مدفوع');

  String get customerName => _s('Customer Name', 'اسم العميل');
  String get phoneNumber => _s('Phone Number', 'رقم الهاتف');
  String get gigabytes => _s('Gigabytes (GB)', 'الجيجابايت (GB)');
  String get price => _s('Price', 'السعر');
  String get notes => _s('Notes', 'ملاحظات');
  String get lastPaidDate => _s('Last Paid', 'آخر دفع');

  String get saveCustomer => _s('Save Customer', 'حفظ العميل');
  String get addNewCustomer => _s('Add New Customer', 'إضافة عميل جديد');

  String get groupFullTitle => _s('Group Full', 'الجروب ممتلئ');
  String get groupFullMessage => _s(
      'This group is full. The maximum is 6 numbers.',
      'الجروب ده كامل، الحد الأقصى 6 أرقام.');

  String get deleteCustomerTitle =>
      _s('Delete Customer?', 'حذف العميل؟');
  String get deleteCustomerMessage => _s(
      'Are you sure you want to delete this customer?',
      'هل أنت متأكد من حذف هذا العميل؟');
  String get resetDemoTitle => _s('Reset Demo Data?', 'إعادة ضبط البيانات؟');
  String get resetDemoMessage => _s(
      'This will erase all customers and history and recreate demo data.',
      'سيتم حذف كل العملاء والسجل وإعادة إنشاء البيانات الافتراضية.');

  String get confirm => _s('Confirm', 'تأكيد');
  String get cancel => _s('Cancel', 'إلغاء');
  String get ok => _s('OK', 'حسنًا');
  String get yes => _s('Yes', 'نعم');
  String get no => _s('No', 'لا');
  String get save => _s('Save', 'حفظ');
  String get delete => _s('Delete', 'حذف');
  String get edit => _s('Edit', 'تعديل');
  String get close => _s('Close', 'إغلاق');

  String get validationRequired =>
      _s('This field is required', 'هذا الحقل مطلوب');
  String get validationGreaterThanZero =>
      _s('Value must be greater than 0', 'القيمة يجب أن تكون أكبر من 0');
  String get validationGreaterOrEqualZero =>
      _s('Value must be 0 or greater', 'القيمة يجب أن تكون 0 أو أكثر');
  String get validationInvalidNumber =>
      _s('Invalid number', 'رقم غير صالح');

  String get successSaved => _s('Saved successfully', 'تم الحفظ بنجاح');
  String get successDeleted => _s('Deleted successfully', 'تم الحذف بنجاح');
  String get successPaymentUpdated =>
      _s('Payment status updated', 'تم تحديث حالة الدفع');

  String get historyTitle => _s('History', 'السجل');
  String get historyEmpty => _s('No previous cycles yet', 'لا توجد دورات سابقة بعد');
  String get filterAll => _s('All Groups', 'كل الجروبات');
  String get filterByGroup => _s('Filter by Group', 'تصفية حسب الجروب');
  String get historyDetails => _s('Cycle Details', 'تفاصيل الدورة');
  String get cycle => _s('Cycle', 'الدورة');
  String get snapshot => _s('Customers Snapshot', 'نسخة العملاء');

  String get settingsTitle => _s('Settings', 'الإعدادات');
  String get language => _s('Language', 'اللغة');
  String get arabic => 'العربية';
  String get english => 'English';
  String get appInfo => _s('App Info', 'معلومات التطبيق');
  String get appVersion => _s('Version', 'الإصدار');
  String get resetDemo =>
      _s('Reset Demo Data', 'إعادة ضبط البيانات الافتراضية');
  String get about => _s(
      'WE Packages Manager — Offline tool for WE resellers.',
      'إدارة باقات WE — تطبيق محلي بدون إنترنت لموزعي WE.');

  String get currency => _s('EGP', 'ج.م');
  String get noCustomers =>
      _s('No customers yet. Tap + to add.', 'لا يوجد عملاء بعد. اضغط + للإضافة.');
  String get addFirstCustomer =>
      _s('Add your first customer', 'أضف أول عميل');

  String get splashLoading => _s('Loading…', 'جاري التحميل…');
  String get demoCustomerName => _s('Customer', 'عميل');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
