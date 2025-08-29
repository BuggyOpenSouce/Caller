import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const CallerApp());
}

class CallerApp extends StatelessWidget {
  const CallerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caller',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('tr', ''),
      ],
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _currentNumber = '';
  List<Contact> _contacts = [];
  List<String> _callHistory = [];
  bool _isLoading = false;
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPreferences();
    _requestPermissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'en';
      _callHistory = prefs.getStringList('call_history') ?? [];
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _selectedLanguage);
    await prefs.setStringList('call_history', _callHistory);
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.phone,
      Permission.contacts,
      Permission.microphone,
    ].request();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    try {
      final contacts = await ContactsService.getContacts();
      setState(() {
        _contacts = contacts.toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error loading contacts: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _makeCall(String number) async {
    if (number.isEmpty) return;
    
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      _addToCallHistory(number);
    } else {
      _showSnackBar('Cannot make call to $number');
    }
  }

  void _addToCallHistory(String number) {
    setState(() {
      _callHistory.insert(0, '$number - ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
      if (_callHistory.length > 50) _callHistory.removeLast();
    });
    _savePreferences();
  }

  void _addDigit(String digit) {
    setState(() {
      _currentNumber += digit;
    });
  }

  void _removeDigit() {
    if (_currentNumber.isNotEmpty) {
      setState(() {
        _currentNumber = _currentNumber.substring(0, _currentNumber.length - 1);
      });
    }
  }

  void _clearNumber() {
    setState(() {
      _currentNumber = '';
    });
  }

  String _getLocalizedText(String key) {
    final texts = {
      'en': {
        'dialer': 'Dialer',
        'contacts': 'Contacts',
        'history': 'History',
        'settings': 'Settings',
        'call': 'Call',
        'clear': 'Clear',
        'search_contacts': 'Search contacts...',
        'no_contacts': 'No contacts found',
        'no_history': 'No call history',
        'language': 'Language',
        'english': 'English',
        'turkish': 'Turkish',
        'ringtone_settings': 'Ringtone Settings',
        'default_ringtone': 'Default Ringtone',
        'calling_sound': 'Calling Sound',
        'vibration': 'Vibration',
        'theme': 'Theme',
        'about': 'About',
        'version': 'Version 1.0.0',
        'made_with_flutter': 'Made with Flutter',
      },
      'tr': {
        'dialer': 'Çevirici',
        'contacts': 'Kişiler',
        'history': 'Geçmiş',
        'settings': 'Ayarlar',
        'call': 'Ara',
        'clear': 'Temizle',
        'search_contacts': 'Kişi ara...',
        'no_contacts': 'Kişi bulunamadı',
        'no_history': 'Arama geçmişi yok',
        'language': 'Dil',
        'english': 'İngilizce',
        'turkish': 'Türkçe',
        'ringtone_settings': 'Zil Sesi Ayarları',
        'default_ringtone': 'Varsayılan Zil Sesi',
        'calling_sound': 'Arama Sesi',
        'vibration': 'Titreşim',
        'theme': 'Tema',
        'about': 'Hakkında',
        'version': 'Sürüm 1.0.0',
        'made_with_flutter': 'Flutter ile yapıldı',
      },
    };
    return texts[_selectedLanguage]?[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caller'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.dialpad), text: _getLocalizedText('dialer')),
            Tab(icon: const Icon(Icons.contacts), text: _getLocalizedText('contacts')),
            Tab(icon: const Icon(Icons.history), text: _getLocalizedText('history')),
            Tab(icon: const Icon(Icons.settings), text: _getLocalizedText('settings')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDialerTab(),
          _buildContactsTab(),
          _buildHistoryTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildDialerTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _currentNumber.isEmpty ? 'Enter number' : _currentNumber,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              ...['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#']
                  .map((digit) => _buildDialButton(digit)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _clearNumber,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text(_getLocalizedText('clear')),
              ),
              ElevatedButton(
                onPressed: () => _makeCall(_currentNumber),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.call),
                    const SizedBox(width: 8),
                    Text(_getLocalizedText('call')),
                  ],
                ),
              ),
              IconButton(
                onPressed: _removeDigit,
                icon: const Icon(Icons.backspace),
                iconSize: 30,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDialButton(String digit) {
    return ElevatedButton(
      onPressed: () => _addDigit(digit),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
      ),
      child: Text(
        digit,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildContactsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: _getLocalizedText('search_contacts'),
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              // Implement search functionality
            },
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _contacts.isEmpty
                  ? Center(child: Text(_getLocalizedText('no_contacts')))
                  : ListView.builder(
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) {
                        final contact = _contacts[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              contact.displayName?.isNotEmpty == true
                                  ? contact.displayName![0].toUpperCase()
                                  : '?',
                            ),
                          ),
                          title: Text(contact.displayName ?? 'Unknown'),
                          subtitle: Text(
                            contact.phones?.isNotEmpty == true
                                ? contact.phones!.first.value ?? ''
                                : 'No phone',
                          ),
                          onTap: () {
                            if (contact.phones?.isNotEmpty == true) {
                              _makeCall(contact.phones!.first.value ?? '');
                            }
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return _callHistory.isEmpty
        ? Center(child: Text(_getLocalizedText('no_history')))
        : ListView.builder(
            itemCount: _callHistory.length,
            itemBuilder: (context, index) {
              final call = _callHistory[index];
              return ListTile(
                leading: const Icon(Icons.call_made),
                title: Text(call),
                trailing: IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () {
                    final number = call.split(' - ')[0];
                    _makeCall(number);
                  },
                ),
              );
            },
          );
  }

  Widget _buildSettingsTab() {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(_getLocalizedText('language')),
          subtitle: Text(_selectedLanguage == 'en' 
              ? _getLocalizedText('english') 
              : _getLocalizedText('turkish')),
          trailing: DropdownButton<String>(
            value: _selectedLanguage,
            items: [
              DropdownMenuItem(
                value: 'en',
                child: Text(_getLocalizedText('english')),
              ),
              DropdownMenuItem(
                value: 'tr',
                child: Text(_getLocalizedText('turkish')),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedLanguage = value;
                });
                _savePreferences();
              }
            },
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.music_note),
          title: Text(_getLocalizedText('ringtone_settings')),
          subtitle: Text(_getLocalizedText('default_ringtone')),
          onTap: () {
            FlutterRingtonePlayer.playRingtone();
          },
        ),
        ListTile(
          leading: const Icon(Icons.volume_up),
          title: Text(_getLocalizedText('calling_sound')),
          onTap: () {
            FlutterRingtonePlayer.playNotification();
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.vibration),
          title: Text(_getLocalizedText('vibration')),
          value: true,
          onChanged: (value) {
            if (value) {
              HapticFeedback.vibrate();
            }
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.palette),
          title: Text(_getLocalizedText('theme')),
          subtitle: const Text('Light'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.info),
          title: Text(_getLocalizedText('about')),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_getLocalizedText('version')),
              Text(_getLocalizedText('made_with_flutter')),
            ],
          ),
        ),
      ],
    );
  }
}

