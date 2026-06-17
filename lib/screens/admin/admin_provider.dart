import 'package:flutter/material.dart';
import '../../helpers/admin_database_helper.dart';
import '../../helpers/admin_prefs_helper.dart';

class AdminProvider extends ChangeNotifier {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> articles = [];
  List<Map<String, dynamic>> rewards = [];
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> queues = [];
  
  int totalJunksPoinInCirculation = 0;
  bool isDarkMode = false;
  String sortOrder = 'Poin Terendah';
  String queueFilter = 'Semua';
  
 
  String lastSyncTime = '';

  Future<void> refreshDashboard() async {
    String savedTheme = await PrefsHelper.getTheme();
    isDarkMode = savedTheme == 'dark';
    
    sortOrder = await PrefsHelper.getSortOrder();
    queueFilter = await PrefsHelper.getQueueFilter();
    
    // ---> LOGIKA BUAT NYATET JAM SEKARANG <---
    final now = DateTime.now();
    final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    await PrefsHelper.setLastSync(timeString);
    lastSyncTime = await PrefsHelper.getLastSync();
    
    await fetchUsers();
    await fetchArticles();
    await fetchRewards();
    await fetchTransactions();
    await fetchQueues();
    notifyListeners();
  }

  Future<void> toggleTheme([bool? value]) async {
    if (value != null) {
      isDarkMode = value;
    } else {
      isDarkMode = !isDarkMode;
    }
    await PrefsHelper.setTheme(isDarkMode ? 'dark' : 'light');
    notifyListeners();
  }

  // USER
  Future<void> fetchUsers() async {
    users = await DatabaseHelper.instance.readAllUsers();
    notifyListeners();
  }
  Future<void> addUser(String username, String password, String role) async {
    await DatabaseHelper.instance.insertUser({'username': username, 'password': password, 'role': role, 'status': 'Active', 'impact_score': 0});
    await fetchUsers();
  }
  Future<void> updateUserStatus(int id, String newStatus) async {
    final user = users.firstWhere((u) => u['id'] == id);
    final updatedUser = Map<String, dynamic>.from(user);
    updatedUser['status'] = newStatus;
    await DatabaseHelper.instance.updateUser(updatedUser);
    await fetchUsers();
  }
  Future<void> deleteUser(int id) async {
    await DatabaseHelper.instance.deleteUser(id);
    await fetchUsers();
  }

  // ARTICLE
  Future<void> fetchArticles() async {
    articles = await DatabaseHelper.instance.readAllArticles();
    notifyListeners();
  }
  Future<void> addArticle(String title, String category, String tag, String content) async {
    await DatabaseHelper.instance.insertArticle({'title': title, 'category': category, 'tag': tag, 'content': content});
    await fetchArticles();
  }
  Future<void> updateArticle(int id, String newTitle, String newCategory, String newTag, String newContent) async {
    await DatabaseHelper.instance.updateArticle({'id': id, 'title': newTitle, 'category': newCategory, 'tag': newTag, 'content': newContent});
    await fetchArticles();
  }
  Future<void> deleteArticle(int id) async {
    await DatabaseHelper.instance.deleteArticle(id);
    await fetchArticles();
  }

  // REWARD
  Future<void> fetchRewards() async {
    final rawData = await DatabaseHelper.instance.readAllRewards();
    List<Map<String, dynamic>> modifiableList = List<Map<String, dynamic>>.from(rawData);
    if (sortOrder == 'Poin Terendah') {
      modifiableList.sort((a, b) => a['points_required'].compareTo(b['points_required']));
    } else {
      modifiableList.sort((a, b) => b['points_required'].compareTo(a['points_required']));
    }
    rewards = modifiableList;
    notifyListeners();
  }
  Future<void> updateSortOrder(String newOrder) async {
    sortOrder = newOrder;
    await PrefsHelper.setSortOrder(newOrder);
    await fetchRewards();
  }
  Future<void> addReward(String name, int points, int stock) async {
    await DatabaseHelper.instance.insertReward({'name': name, 'points_required': points, 'stock': stock});
    await fetchRewards();
  }
  Future<void> updateReward(int id, String name, int points, int stock) async {
    await DatabaseHelper.instance.updateReward({'id': id, 'name': name, 'points_required': points, 'stock': stock});
    await fetchRewards();
  }
  Future<void> deleteReward(int id) async {
    await DatabaseHelper.instance.deleteReward(id);
    await fetchRewards();
  }

  // TRANSACTIONS
  Future<void> fetchTransactions() async {
    transactions = await DatabaseHelper.instance.readAllTransactions();
    totalJunksPoinInCirculation = transactions.fold(0, (sum, item) {
      return item['type'] == 'Earn' ? sum + (item['points'] as int) : sum - (item['points'] as int);
    });
    notifyListeners();
  }

  // QUEUE ROUND-ROBIN
  Future<void> fetchQueues() async {
    final rawData = await DatabaseHelper.instance.readAllQueues();
    if (queueFilter == 'Semua') {
      queues = rawData;
    } else {
      queues = rawData.where((q) => q['status'] == queueFilter).toList();
    }
    notifyListeners();
  }
  Future<void> updateQueueFilter(String newFilter) async {
    queueFilter = newFilter;
    await PrefsHelper.setQueueFilter(newFilter);
    await fetchQueues();
  }
  Future<void> addQueue(String name, String type, int quota) async {
    await DatabaseHelper.instance.insertQueue({'farmer_name': name, 'farm_type': type, 'quota_kg': quota, 'status': 'Menunggu'});
    await fetchQueues();
  }
  Future<void> updateQueueStatus(int id, String name, String type, int quota, String status) async {
    await DatabaseHelper.instance.updateQueue({'id': id, 'farmer_name': name, 'farm_type': type, 'quota_kg': quota, 'status': status});
    await fetchQueues();
  }
  Future<void> deleteQueue(int id) async {
    await DatabaseHelper.instance.deleteQueue(id);
    await fetchQueues();
  }
}