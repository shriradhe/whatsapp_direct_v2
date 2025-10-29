import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contact.dart';

class WhatsAppService {
  static const String _recentContactsKey = 'recent_contacts';
  static const int _maxRecentContacts = 10;

  Future<bool> sendMessage({
    required String phoneNumber,
    required String countryCode,
    String? message,
  }) async {
    try {
      final sanitizedCountryCode = countryCode.replaceAll(RegExp(r'\D'), '');
      final sanitizedPhoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
      final fullNumber = sanitizedCountryCode + sanitizedPhoneNumber;
      final encodedMessage = message != null && message.isNotEmpty ? Uri.encodeComponent(message) : '';
      
      final whatsappNativeUrl = Uri.parse('whatsapp://send?phone=$fullNumber&text=$encodedMessage');
      final whatsappWebUrl = Uri.parse('https://wa.me/$fullNumber?text=$encodedMessage');
      
      bool launched = false;
      
      if (await canLaunchUrl(whatsappNativeUrl)) {
        launched = await launchUrl(
          whatsappNativeUrl,
          mode: LaunchMode.externalNonBrowserApplication,
        );
      }
      
      if (!launched && await canLaunchUrl(whatsappWebUrl)) {
        launched = await launchUrl(
          whatsappWebUrl,
          mode: LaunchMode.externalApplication,
        );
      }
      
      if (launched) {
        await _saveRecentContact(
          phoneNumber: phoneNumber,
          countryCode: countryCode,
          message: message ?? '',
        );
      }
      
      return launched;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveRecentContact({
    required String phoneNumber,
    required String countryCode,
    required String message,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final contacts = await getRecentContacts();
    
    contacts.removeWhere((c) => 
      c.phoneNumber == phoneNumber && c.countryCode == countryCode
    );
    
    contacts.insert(
      0,
      Contact(
        phoneNumber: phoneNumber,
        countryCode: countryCode,
        lastMessage: message,
        timestamp: DateTime.now(),
      ),
    );
    
    if (contacts.length > _maxRecentContacts) {
      contacts.removeRange(_maxRecentContacts, contacts.length);
    }
    
    final jsonList = contacts.map((c) => c.toJson()).toList();
    await prefs.setString(_recentContactsKey, json.encode(jsonList));
  }

  Future<List<Contact>> getRecentContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_recentContactsKey);
    
    if (jsonString == null) {
      return [];
    }
    
    try {
      final jsonList = json.decode(jsonString) as List;
      return jsonList.map((json) => Contact.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearRecentContacts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentContactsKey);
  }

  Future<bool> isWhatsAppInstalled() async {
    final whatsappUrl = Uri.parse('https://wa.me/1234567890');
    return await canLaunchUrl(whatsappUrl);
  }
}
