import 'package:uuid/uuid.dart';
import 'package:flutter_treeview/flutter_treeview.dart';

class Entry {
  String? name;
  Entry(this.name);
}

class Account extends Entry {
  double balance = 0;
  Account? parent; // If null, this account is a root
  List<Account> children = [];
  List<Transaction> transactionList = [];
  Account(String? name, double? balance, {Account? parent}) : super(name) {
    // ignore: prefer_initializing_formals]
    this.parent = parent;
    this.parent?.children.add(this);
    this.balance = balance ?? 0;
  }

  bool isRoot() {
    return parent == null;
  }

  void addTransaction(Transaction t) {
    transactionList.add(t);
  }

  void adjustBalance(double cost) {
    balance += cost;
  }

  Node toNode() {
    String label = '${name} \$${balance}';
    return Node(
      key: name ?? "",
      label: label,
      children: children.map((account) => account.toNode()).toList(),
    );
  }

  Account copySignature() {
    return Account(name, balance, parent: parent);
  }
}

class Transaction {
  String name;
  double dollarAmount;
  late String id;
  DateTime date;
  Account accountTo;
  Account accountFrom;

  Transaction(this.name, this.date, this.dollarAmount, this.accountTo,
      this.accountFrom) {
    id = const Uuid().v1();
    accountTo.addTransaction(this);
    accountFrom.addTransaction(this);
    accountTo.adjustBalance(dollarAmount);
    accountFrom.adjustBalance(-dollarAmount);
  }
}
