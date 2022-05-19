// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_finance/main.dart';
import 'package:flutter_finance/models/finance_objects.dart';

void main() {
  testWidgets('Object Structure Behaves as Expected',
      (WidgetTester tester) async {
    Account bankAccount = Account("Savings");
    Account goalAccount = Account("Goal");
    Transaction transfer =
        Transaction("Contribute", DateTime.now(), 10, goalAccount, bankAccount);
    assert(goalAccount.transactionList[0] == bankAccount.transactionList[0]);
    assert(
        goalAccount.transactionList[0].id == bankAccount.transactionList[0].id);
    assert(goalAccount.balance == 10);
    assert(bankAccount.balance == -10);

    // Account Hiearchy
    assert(bankAccount.isRoot());
    assert(goalAccount.isRoot());

    Account savingsChild = Account("Savings Child", parent: bankAccount);
    assert(savingsChild.parent == bankAccount);
    assert(bankAccount.children.contains(savingsChild));
    assert(!savingsChild.isRoot());
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FinanceApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
