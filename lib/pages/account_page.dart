import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:flutter_finance/views/states.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finance/models/finance_objects.dart';

class AccountPage extends StatefulWidget {
  AccountPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String _selectedNode = "";
  List<Node> _nodes = [];
  late TreeViewController _treeViewController;
  bool docsOpen = true;
  bool deepExpanded = true;
  GlobalKey<FormState> _addAccountFormKey = GlobalKey<FormState>();

  String _newAccountName = "";
  double _newAccountBalance = 0;

  @override
  void initState() {
    _nodes = [];
    _treeViewController = TreeViewController(
      children: _nodes,
      selectedKey: _selectedNode,
    );

    super.initState();
  }

  void _addAccount() {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Account'),
          content: SingleChildScrollView(
              child: Form(
            key: _addAccountFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Account Name',
                  ),
                  validator: (String? accountName) {
                    if (accountName == null || accountName.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  onSaved: (String? accountName) {
                    _newAccountName = accountName ?? "";
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Initial Balance',
                  ),
                  validator: (String? balance) {
                    double initialBalance = double.parse(balance ?? "0");
                    if (initialBalance.isNaN) {
                      return 'Please enter a valid balance.';
                    }
                    return null;
                  },
                  onSaved: (String? balance) {
                    _newAccountBalance = double.parse(balance ?? "0");
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Validate will return true if the form is valid, or false if
                      // the form is invalid.
                      if (_addAccountFormKey.currentState!.validate()) {
                        _addAccountFormKey.currentState!.save();
                        setState(() {
                          Account newAccount =
                              Account(_newAccountName, _newAccountBalance);
                          _nodes.add(newAccount.toNode());
                        });
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          )),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TreeViewTheme _treeViewTheme = TreeViewTheme(
      expanderTheme: const ExpanderThemeData(
          type: ExpanderType.caret,
          modifier: ExpanderModifier.none,
          position: ExpanderPosition.start,
          // color: Colors.grey.shade800,
          size: 20,
          color: Colors.blue),
      labelStyle: const TextStyle(
        fontSize: 16,
        letterSpacing: 0.3,
      ),
      parentLabelStyle: TextStyle(
        fontSize: 16,
        letterSpacing: 0.1,
        fontWeight: FontWeight.w800,
        color: Colors.blue.shade700,
      ),
      iconTheme: IconThemeData(
        size: 18,
        color: Colors.grey.shade800,
      ),
      colorScheme: Theme.of(context).colorScheme,
    );

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      drawer: Drawer(
          child: ListView(
        children: [
          DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text("Options")),
          ListTile(
            leading: Icon(Icons.message),
            title: Text('Add Account'),
            onTap: _addAccount,
          ),
        ],
      )),
      body: TreeView(
        controller: _treeViewController,
        allowParentSelect: true,
        supportParentDoubleTap: false,
        onExpansionChanged: (key, expanded) => _expandNode(key, expanded),
        onNodeTap: (key) {
          debugPrint('Selected: $key');
          setState(() {
            _selectedNode = key;
            _treeViewController =
                _treeViewController.copyWith(selectedKey: key);
          });
        },
        theme: _treeViewTheme,
      ),
    );
  }

  _expandNode(String key, bool expanded) {
    String msg = '${expanded ? "Expanded" : "Collapsed"}: $key';
    debugPrint(msg);
    Node? node = _treeViewController.getNode(key);
    if (node != null) {
      List<Node> updated;
      if (key == 'docs') {
        updated = _treeViewController.updateNode(
            key,
            node.copyWith(
              expanded: expanded,
              icon: expanded ? Icons.folder_open : Icons.folder,
            ));
      } else {
        updated = _treeViewController.updateNode(
            key, node.copyWith(expanded: expanded));
      }
      setState(() {
        if (key == 'docs') docsOpen = expanded;
        _treeViewController = _treeViewController.copyWith(children: updated);
      });
    }
  }
}

class ModContainer extends StatelessWidget {
  final ExpanderModifier modifier;

  const ModContainer(this.modifier, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _borderWidth = 0;
    BoxShape _shapeBorder = BoxShape.rectangle;
    Color _backColor = Colors.transparent;
    Color _backAltColor = Colors.grey.shade700;
    switch (modifier) {
      case ExpanderModifier.none:
        break;
      case ExpanderModifier.circleFilled:
        _shapeBorder = BoxShape.circle;
        _backColor = _backAltColor;
        break;
      case ExpanderModifier.circleOutlined:
        _borderWidth = 1;
        _shapeBorder = BoxShape.circle;
        break;
      case ExpanderModifier.squareFilled:
        _backColor = _backAltColor;
        break;
      case ExpanderModifier.squareOutlined:
        _borderWidth = 1;
        break;
    }
    return Container(
      decoration: BoxDecoration(
        shape: _shapeBorder,
        border: _borderWidth == 0
            ? null
            : Border.all(
                width: _borderWidth,
                color: _backAltColor,
              ),
        color: _backColor,
      ),
      width: 15,
      height: 15,
    );
  }
}
