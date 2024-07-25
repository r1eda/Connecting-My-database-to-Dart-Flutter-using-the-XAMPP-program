import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Database App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  // String host = '192.168.0.103';
  // String password = '1234';
  final settings = ConnectionSettings(
    // localhost
    host: 'localhost',
    port: 3306,
    user: 'Reda',
    db: 'test',
    password: '1234',
  );
  Future<void> fetchStudents() async {
    final conn = await MySqlConnection.connect(settings);
    try {
      var results = await conn.query('SELECT * FROM student');
      List<Map<String, dynamic>> tempStudents = [];

      for (var row in results) {
        tempStudents.add({
          'Id': row['Id'],
          'FName': row['FName'],
          'LName': row['LName'],
          'City': row['City'],
        });
      }

      setState(() {
        students = tempStudents;
      });
    } catch (e) {
      print('Error: $e');
    } finally {
      await conn.close();
    }
  }

  Future<void> addStudent(String fName, String lName, String city) async {
    final conn = await MySqlConnection.connect(settings);

    try {
      await conn.query(
          'INSERT INTO student (FName, LName, City) VALUES (?, ?, ?)',
          [fName, lName, city]);
      fetchStudents();
    } catch (e) {
      print('Error: $e');
    } finally {
      await conn.close();
    }
  }

  Future<void> deleteStudent(int id) async {
    final conn = await MySqlConnection.connect(settings);

    try {
      await conn.query('DELETE FROM student WHERE Id = ?', [id]);
      fetchStudents();
    } catch (e) {
      print('Error: $e');
    } finally {
      await conn.close();
    }
  }

  Future<void> updateStudent(
      int id, String fName, String lName, String city) async {
    final conn = await MySqlConnection.connect(settings);

    try {
      await conn.query(
          'UPDATE student SET FName = ?, LName = ?, City = ? WHERE Id = ?',
          [fName, lName, city, id]);
      fetchStudents();
    } catch (e) {
      print('Error: $e');
    } finally {
      await conn.close();
    }
  }

  void showAddStudentDialog() {
    TextEditingController fNameController = TextEditingController();
    TextEditingController lNameController = TextEditingController();
    TextEditingController cityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: fNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: lNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: cityController,
              decoration: InputDecoration(labelText: 'City'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              addStudent(fNameController.text, lNameController.text,
                  cityController.text);
              Navigator.of(context).pop();
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void showUpdateStudentDialog(Map<String, dynamic> student) {
    TextEditingController fNameController =
        TextEditingController(text: student['FName']);
    TextEditingController lNameController =
        TextEditingController(text: student['LName']);
    TextEditingController cityController =
        TextEditingController(text: student['City']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: fNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: lNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: cityController,
              decoration: InputDecoration(labelText: 'City'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              updateStudent(student['Id'], fNameController.text,
                  lNameController.text, cityController.text);
              Navigator.of(context).pop();
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Students List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: showAddStudentDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchStudents,
        child: students.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                        '${students[index]['FName']} ${students[index]['LName']}'),
                    subtitle: Text('City: ${students[index]['City']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            showUpdateStudentDialog(students[index]);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            deleteStudent(students[index]['Id']);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
