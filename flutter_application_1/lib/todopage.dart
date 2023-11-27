import 'package:flutter/material.dart';
import 'package:flutter_application_1/databasehelper.dart';
import 'package:flutter_application_1/todo.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({
    super.key,
  });

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  TextEditingController _namaCtrl = TextEditingController();
  TextEditingController _deskripsi = TextEditingController();
  TextEditingController _search = TextEditingController();
  List<Todo> todolist = Todo.dummyData;
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshlist();
  }

  void refreshlist() async {
    final todos = await dbHelper.getAllTodos();
    setState(() {
      todolist = todos;
    });
  }

  void updateitem(int index, bool done) async {
    todolist[index].done = done;
    await dbHelper.updateTodo(todolist[index]);
    refreshlist();
  }

  void addItem() async {
    await dbHelper.addTodo(Todo(_namaCtrl.text, _deskripsi.text));
    // todolist.add(Todo(_namaCtrl.text, _deskripsi.text));
    refreshlist();
    _namaCtrl.text = '';
    _deskripsi.text = '';
  }

  void CariTodo() async {
    String teks = _search.text.trim();
    List<Todo> todos = [];
    if (teks.isEmpty) {
      todos = await dbHelper.getAllTodos();
    } else {
      todos = await dbHelper.SearchAllTodos(teks);
    }
    setState(() {
      todolist = todos;
    });
  }

  void deleteitem(int id) async {
    // todolist.removeAt(index);
    await dbHelper.deleteTodo(id);
    refreshlist();
  }

  void tampilForm() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              insetPadding: EdgeInsets.all(20),
              title: Text("Tambah Todo"),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Tutup",
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      addItem();
                    },
                    child: Text("Tambah")),
              ],
              content: Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                child: Column(
                  children: [
                    TextField(
                      controller: _namaCtrl,
                      decoration: InputDecoration(hintText: 'Nama Todo'),
                    ),
                    TextField(
                      controller: _deskripsi,
                      decoration:
                          InputDecoration(hintText: 'Deskripsi Pekerjaan'),
                    ),
                  ],
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Aplikasi Todo List'),
          backgroundColor: Colors.green,
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            tampilForm();
          },
          child: const Icon(Icons.add_box),
        ),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: TextField(
                controller: _search,
                onChanged: (_) {
                  CariTodo();
                },
                decoration: InputDecoration(
                    hintText: 'searching',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder()),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
                child: ListView.builder(
              itemCount: todolist.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: todolist[index].done
                      ? IconButton(
                          icon: const Icon(Icons.check_circle),
                          onPressed: () {
                            updateitem(index, !todolist[index].done);
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.radio_button_unchecked),
                          onPressed: () {
                            updateitem(index, !todolist[index].done);
                          },
                        ),
                  title: Text(todolist[index].nama),
                  subtitle: Text(todolist[index].deskripsi),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      deleteitem(todolist[index].id ?? 0);
                    },
                  ),
                );
              },
            )),
          ],
        ));
  }
}
