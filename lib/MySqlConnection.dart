import 'package:mysql_client/mysql_client.dart';
import 'package:test_journal/screens/work_with_students/admin_screens/model/student.dart';
import 'dart:math';

import 'package:test_journal/screens/work_with_students/edit_form.dart';

class MySqlConnectionHandler {

  MySQLConnection? _connection;

  Future<bool> loginUser(String user, String pass) async {
    if (_connection == null) {
      print('No database connection found.');
      return false;
    }

    try {
      var result = await _connection!.execute('''
      SELECT * FROM curators WHERE email = :email AND password = :password;
    ''', {
        'email': user,
        'password': pass,
      });
      print('Select query login: ');
      return result.rows.isNotEmpty;

    } catch (e) {
      print('Select query failed: $e');
      return false; 
    }
  }

  Future<List<Map<String, dynamic>>> selectCuratorInfo(String user, String pass) async {
    if (_connection == null) {
      print('No database connection found.');
      return [];
    }

    List<Map<String, dynamic>> records = []; 

    try {

      var result = await _connection!.execute('''
      SELECT * FROM curators WHERE email = :email AND password = :password;
    ''', {
        'email': user,
        'password': pass,
      });

      for (final row in result.rows) {
        var record = row.assoc();
        records.add(record);
      }
      print('Select query selectCuratorInfo');

    } catch (e) {
      print('Select query failed: $e');
    }

    return records; 
  }

  Future<List<Map<String, dynamic>>> checkEmail(String user) async {
    if (_connection == null) {
      print('No database connection found.');
      return [];
    }

    List<Map<String, dynamic>> records = [];

    try {

      var result = await _connection!.execute('''
      SELECT * FROM curators WHERE email = :email;
    ''', {
        'email': user
      });

      for (final row in result.rows) {
        var record = row.assoc();
        records.add(record);
      }
      print('Select query checkEmail');

    } catch (e) {
      print('Select query failed: $e');
    }

    return records;
  }

  Future<List<Map<String, dynamic>>> selectGenInfo(String group) async {
    if (_connection == null) {
      print('No database connection found.');
      return [];
    }

    List<Map<String, dynamic>> records = [];

    try {
      var result = await _connection!.execute('''
        SELECT gi.id, s.second_name, s.first_name, s.middle_name,
               gi.phone_number, gi.date, gi.address, gi.status
        FROM students s 
        JOIN general_info gi ON s.id = gi.id_student
        WHERE s.group = :group;
        ''',
      {'group': group});

      for (final row in result.rows) {
        var record = row.assoc();
        records.add(record);
      }
      print('Select query selectGenInfo');

    } catch (e) {
      print('Select query failed: $e');
    }

    return records; 
  }

  Future<List<Map<String, dynamic>>> selectEduData(String group) async {
    if (_connection == null) {
      print('No database connection found.');
      return [];
    }

    List<Map<String, dynamic>> records = []; 

    try {
      var result = await _connection!.execute('''
        SELECT ed.id, s.second_name, s.first_name, s.middle_name,
               ed.average_score, ed.end_date, ed.institution_name
        FROM students s 
        JOIN education_data ed ON s.id = ed.id_student 
        WHERE s.group = :group;
        ''',
          {'group': group});
      for (final row in result.rows) {
        var record = row.assoc();
        records.add(record);
      }
      print('Select query selectEduData');

    } catch (e) {
      print('Select query failed: $e');
    }

    return records; 
  }

  Future<List<Map<String, dynamic>>> selectServInArmyData(String group) async {
    if (_connection == null) {
      print('No database connection found.');
      return [];
    }

    List<Map<String, dynamic>> records = []; 

    try {

      var result = await _connection!.execute('''
        SELECT sia.id, s.second_name, s.first_name, s.middle_name, 
               sia.start_date, sia.end_date, sia.unit
        FROM students s 
        JOIN service_in_army sia ON s.id = sia.id_student
        WHERE s.group = :group;
        ''',
          {'group': group});
      for (final row in result.rows) {
        var record = row.assoc();
        records.add(record);
      }
      print('Select query selectServInArmyData');

    } catch (e) {
      print('Select query failed: $e');
    }

    return records; 
  }

  Future<List<Map<String, dynamic>>> selectJobActivityData(String group) async {
    if (_connection == null) {
      print('No database connection found.');
      return [];
    }

    List<Map<String, dynamic>> records = []; 

    try {

      var result = await _connection!.execute('''
        SELECT ja.id, s.second_name, s.first_name, s.middle_name,
               ja.end_date, ja.start_date, ja.place, ja.job_position, ja.phone_number
        FROM students s 
        JOIN job_activity ja ON s.id = ja.id_student
        WHERE s.group = :group;
        ''',
          {'group': group});
      for (final row in result.rows) {
        var record = row.assoc();
        records.add(record);
      }
      print('Select query selectJobActivityData');

    } catch (e) {
      print('Select query failed: $e');
    }

    return records; 
  }

  Future<List<Map<String, dynamic>>> selectParentsInfoData(String group) async {
    if (_connection == null) {
      print('No database connection found.');
      return [];
    }

    List<Map<String, dynamic>> records = []; 

    try {

      var result = await _connection!.execute('''
        SELECT pi.id, s.second_name, s.first_name, s.middle_name, s.group,
               pi.father, pi.fathers_phone, pi.mother, pi.mothers_phone, pi.note
        FROM students s 
        JOIN parents_info pi ON s.id = pi.id_student
        WHERE s.group = :group;
        ''',
          {'group': group});
      for (final row in result.rows) {
        var record = row.assoc();
        records.add(record);
      }
      print('Select query selectParentsInfoData');

    } catch (e) {
      print('Select query failed: $e');
    }

    return records; 
  }

  Future<List<Map<String, dynamic>>> selectStudentData(String group) async {
    if (_connection == null) {
      print('No database connection found.');
      return [];
    }

    List<Map<String, dynamic>> records = []; 

    try {

      var result = await _connection!.execute('''
        SELECT * FROM students where `group` = :group order by second_name asc;
      ''',
        {
          'group': group,
        }
      );
      for (final row in result.rows) {
        var record = row.assoc();
        records.add(record);
      }
      print('Select query selectStudentData');

    } catch (e) {
      print('Select query failed: $e');
    }

    return records; 
  }
eturn records; 
  }


  Future<List<Map<String, dynamic>>> selectSocialActivity(String group) async {
    if (_connection == null) {
      print('No database connection found.');
      return [];
    }

    List<Map<String, dynamic>> records = []; 

    try {
      // s.id,
    var result = await _connection!.execute('''
        SELECT s.second_name, s.first_name, s.middle_name, 
               sa.id, sa.session, sa.date, sa.activity
        FROM students s 
        JOIN social_activity sa ON s.id = sa.id_student
        WHERE s.group = :group;
        ''',
          {'group': group});
      for (final row in result.rows) {
        var record = row.assoc();
        records.add(record);
      }
    print('Select query selectSocialActivity');

    } catch (e) {
      print('Select query failed: $e');
    }

    return records; 
  }

  Future<List<Map<String, dynamic>>> selectCircleActivity(String group) async {
    if (_connection == null) {
      print('No database connection found.');
      return [];
    }

    List<Map<String, dynamic>> records = []; 

    try {

      var result = await _connection!.execute('''
        SELECT ca.id, s.second_name, s.first_name, s.middle_name, 
               ca.session, ca.circle_name, ca.note
        FROM students s 
        JOIN circle_activity ca ON s.id = ca.id_student
        WHERE s.group = :group;
        ''',
          {'group': group});
      for (final row in result.rows) {
        var record = row.assoc();
        records.add(record);
      }
      print('Select query selectCircleActivity');

    } catch (e) {
      print('Select query failed: $e');
    }

    return records; 
  }

  Future<List<Map<String, dynamic>>> selectIndividualEscort(String group) async {
    if (_connection == null) {
      print('No database connection found.');
      return [];
    }

    List<Map<String, dynamic>> records = []; 

    try {

      var result = await _connection!.execute('''
        SELECT ie.id, s.second_name, s.first_name, s.middle_name, 
               ie.session, ie.date, ie.content
        FROM students s 
        JOIN individual_escort ie ON s.id = ie.id_student
        WHERE s.group = :group;
        ''',
          {'group': group});
      for (final row in result.rows) {
        var record = row.assoc();
        records.add(record);
      }
      print('Select query selectIndividualEscort');

    } catch (e) {
      print('Select query failed: $e');
    }
    return records; 
  }

  Future<List<Map<String, dynamic>>> selectEncouragement(String group) async {
    if (_connection == null) {
      print('No database connection found.');
      return [];
    }

    List<Map<String, dynamic>> records = []; 

    try {

      var result = await _connection!.execute('''
        SELECT e.id, s.second_name, s.first_name, s.middle_name, 
               e.session, e.date, e.content
        FROM students s 
        JOIN encouragement e ON s.id = e.id_student
        WHERE s.group = :group;
        ''',
          {'group': group});
      for (final row in result.rows) {
        var record = row.assoc();
        records.add(record);
      }
      print('Select query selectEncouragement');

    } catch (e) {
      print('Select query failed: $e');
    }

    return records; 
  }

  Future<List<Map<String, dynamic>>> selectSpDefault(String category) async {
    if (_connection == null) {
      print('No database connection found.');
      return [];
    }

    List<Map<String, dynamic>> records = []; 

    try {

      var result = await _connection!.execute('''
          SELECT cn.category, 
              spc.id, spc.start_date, spc.end_date, 
              s.second_name, s.first_name, s.middle_name, s.`group`
          FROM sp_category_name cn
          JOIN sp_category spc ON cn.id = spc.id_category_name
          JOIN students s ON s.id = spc.id_student
          where cn.category = :category and s.status false
          order by s.`group`, s.second_name;
        ''',
          {'category': category});
      for (final row in result.rows) {
        var record = row.assoc();
        records.add(record);
      }
      print('Select query selectSpDefault:');

    } catch (e) {
      print('Select query failed: $e');
    }

    return records; 
  
  Future<List<Map<String, dynamic>>> selectSpManyChildren() async {
    if (_connection == null) {
      print('No database connection found.');
      return [];
    }

    List<Map<String, dynamic>> records = []; 
    try {

      var result = await _connection!.execute('''
         SELECT cn.category, 
              spc.id, spc.start_date, spc.end_date, 
              s.second_name, s.first_name, s.middle_name, spmc.number_of_children, spmc.less_than_18, spmc.more_than_18_studying, s.`group`
          FROM sp_category_name cn
          JOIN sp_category spc ON cn.id = spc.id_category_name
          JOIN students s ON s.id = spc.id_student
          JOIN sp_many_child_family spmc ON spmc.id_category = spc.id
          where s.status is false
          order by s.`group`, s.second_name;
        ''');
      for (final row in result.rows) {
        var record = row.assoc();
        records.add(record);
      }

      print('Select query selectSpManyChildren: ');

    } catch (e) {
      print('Select query failed: $e');
    }

    return records;
  }
  Future<List<Map<String, dynamic>>> selectSpInvalidPeople() async {
    if (_connection == null) {
      print('No database connection found.');
      return [];
    }

    List<Map<String, dynamic>> records = [];

    try {

      var result = await _connection!.execute('''
          SELECT cn.category, 
            spc.id, spc.start_date, spc.end_date, 
              s.second_name, s.first_name, s.middle_name, spip.invalid_group, s.`group`
          FROM sp_category_name cn
          JOIN sp_category spc ON cn.id = spc.id_category_name
          JOIN students s ON s.id = spc.id_student
          JOIN sp_invalid_people spip ON spip.id_category = spc.id
          where s.status is false
          order by s.`group`, s.second_name;       
         ''',);
      for (final row in result.rows) {
        var record = row.assoc();
        records.add(record);
      }
      print('Select query selectSpInvalidPeople:');

    } catch (e) {
      print('Select query failed: $e');
    }

    return records; 
  }
  Future<List<Map<String, dynamic>>> selectSpChornobyltsi() async {
    if (_connection == null) {
      print('No database connection found.');
      return [];
    }

    List<Map<String, dynamic>> records = [];
    try {

      var result = await _connection!.execute('''
          SELECT cn.category, 
            spc.id, spc.start_date, spc.end_date, 
              s.second_name, s.first_name, s.middle_name, spip.`group` as 'cgroup', s.`group`
          FROM sp_category_name cn
          JOIN sp_category spc ON cn.id = spc.id_category_name
          JOIN students s ON s.id = spc.id_student
          JOIN sp_chornobyltsi spip ON spip.id_category = spc.id
          where s.status is false
          order by s.`group`, s.second_name;       
         ''');
      for (final row in result.rows) {
        var record = row.assoc();
        records.add(record);
      }
      print('Select query selectSpChornobyltsi');

    } catch (e) {
      print('Select query failed: $e');
    }

    return records; 
  }


  Future<List<Map<String, dynamic>>> selectSpCategoryName() async {
    if (_connection == null) {
      print('No database connection found.');
      return [];
    }

    List<Map<String, dynamic>> records = [];

    try {

      var result = await _connection!.execute('SELECT * FROM sp_category_name order by category asc');
      for (final row in result.rows) {
        var record = row.assoc();
        records.add(record);
      }
      print('Select query selectSpCategoryName');

    } catch (e) {
      print('Select query failed: $e');
    }

    return records; 
  }

  Future<List<String>> selectSpCategoryNameOld() async {
    if (_connection == null) {
      print('No database connection found.');
      return [];
    }

    List<String> records = [];

    try {
      var result = await _connection!.execute(
          'SELECT category FROM sp_category_name '
      );

      for (final row in result.rows) {
        var record = row.colAt(0);
        records.add(record!);
      }
      print('Select query selectSpCategoryNameOld');

    } catch (e) {
      print('Select query failed: $e');
    }
    return records;

  }

  Future<List<Map<String, dynamic>>> selectWorkPlanCurator(String creator) async {
    if (_connection == null) {
      print('No database connection found.');
      return [];
    }

    List<Map<String, dynamic>> records = [];

    try {
      var result = await _connection!.execute(
          'SELECT * FROM work_plan where creator = "admin" or creator = :creator ORDER BY execution_date DESC;',
        {
          'creator': creator
        }
      );

      for (final row in result.rows) {
        var record = row.assoc();
        records.add(record);
      }
      print('Select query selectWorkPlanCurator');

    } catch (e) {
      print('Select query failed: $e');
    }
    return records;

  }

  Future<List<Map<String, dynamic>>> selectCurators() async {
    if (_connection == null) {
      print('No database connection found.');
      return [];
    }

    List<Map<String, dynamic>> records = [];

    try {
      var result = await _connection!.execute(
          'SELECT * FROM curators where role != "Адміністратор"'
              'order by second_name;'
      );

      for (final row in result.rows) {
        var record = row.assoc();
        records.add(record);
      }
      print('Select query selectCurators');

    } catch (e) {
      print('Select query failed: $e');
    }
    return records;

  }


  

  Future<List<Map<String, dynamic>>> selectGroups() async {
    if (_connection == null) {
      print('No database connection found.');
      return [];
    }

    List<Map<String, dynamic>> records = [];

    try {
      var result = await _connection!.execute(
          'SELECT * FROM `groups` order by group_name;'
      );

      for (final row in result.rows) {
        var record = row.assoc();
        records.add(record);
      }
      print('Select query selectGroups');

    } catch (e) {
      print('Select query failed: $e');
    }
    return records;

  }

  Future<List<Map<String, dynamic>>> selectGroupsMain(bool isGrad) async {
    if (_connection == null) {
      print('No database connection found.');
      return [];
    }

    List<Map<String, dynamic>> records = [];

    try {
      var result = await _connection!.execute(
          '''
          SELECT 
              g.id, g.`group_name` as "group", g.isGrad,
              IFNULL(GROUP_CONCAT(CONCAT(c.second_name, ' ', c.first_name, ' ', c.middle_name) SEPARATOR ', '), 'Немає куратора') AS curators
          FROM 
              `groups` g
          LEFT JOIN 
              curators c ON g.`group_name` = c.`group`
          where g.isGrad = $isGrad
          GROUP BY 
           g.`group_name`, g.isGrad, g.id

        '''
      );

      for (final row in result.rows) {
        var record = row.assoc();
        records.add(record);
      }
      print('Select query selectGroupsMain');

    } catch (e) {
      print('Select query failed: $e');
    }
    return records;

  }

  Future<List<Map<String, dynamic>>> selectExportSp() async {
    if (_connection == null) {
      print('No database connection found.');
      return [];
    }

    List<Map<String, dynamic>> records = [];

    try {
      var result = await _connection!.execute(
          '''
          SELECT
              s.second_name,
              s.first_name,
              s.middle_name,
              s.`group`,
              gi.date,
              cn.category,
              CASE
                  WHEN TIMESTAMPDIFF(YEAR, gi.date, CURDATE()) >= 18 THEN 'Так'
                  ELSE 'Ні'
                  END AS is_adult
          FROM sp_category_name cn
                   Left JOIN sp_category spc ON cn.id = spc.id_category_name
                   Left JOIN students s ON s.id = spc.id_student
                   Left JOIN general_info gi ON s.id = gi.id_student
          WHERE s.`group` IN (
              SELECT g.group_name
              FROM `groups` g
              WHERE g.isGrad = false
              and s.status is false
          )
          ORDER BY   s.`group`, s.second_name;

        '''
      );

      for (final row in result.rows) {
        var record = row.assoc();
        records.add(record);
      }
      print('Select query selectExportSp');

    } catch (e) {
      print('Select query failed: $e');
    }
    return records;

  }


  Future<void> insertStudent(String secondName, String firstName, String middleName, String group) async {
    var result = await _connection!.execute(
        '''
            INSERT INTO 
            students (second_name, first_name, middle_name, `group`) 
            VALUES (:second_name, :first_name, :middle_name, :group);
         ''',
        {
          'second_name': secondName,
          'first_name': firstName,
          'middle_name': middleName,
          'group': group
        }
    );
    print(result.affectedRows);
  }
  Future<void> updateStudent(int id, String secondName, String firstName, String middleName) async {
    var result = await _connection!.execute(
        ''' 
      UPDATE students
      SET
        second_name = :secondName,  
        first_name = :firstName,          
        middle_name = :middleName
      WHERE id = :id;       
      ''',
        {
          'secondName': secondName,
          'firstName': firstName,
          'middleName': middleName,
          'id': id
        }
    );

    print('Updated rows: ${result.affectedRows}');
  }


  Future<void> insertCurator(String secondName, String firstName, String middleName, String group, String email, String role, String pass) async {
    if (_connection == null) {
      print('No database connection found.');
    }

    // try {


      var result = await _connection!.execute(
          '''
            INSERT INTO 
            curators (second_name, first_name, middle_name, `group`, email, password, role) 
            VALUES (:second_name, :first_name, :middle_name, :group, :email, :password, :role);
         ''',
          {
            'second_name': secondName,
            'first_name': firstName,
            'middle_name': middleName,
            'group': group,
            'email': email,
            'password': pass,
            'role': role,
          }
      );
      print(result.affectedRows);
    // } catch (e) {
    //   print('Insert query failed: $e');
    // }

  }
  Future<void> updateCurator(int id, String secondName, String firstName, String middleName, String group, String email) async {
    var result = await _connection!.execute(
        ''' 
      UPDATE curators
      SET
        second_name = :secondName,  
        first_name = :firstName,          
        middle_name = :middleName, 
        `group` = :group, 
        email = :email
      WHERE id = :id;       
      ''',
        {
          'secondName': secondName,
          'firstName': firstName,
          'middleName': middleName,
          'group': group,
          'email': email,
          'id': id
        }
    );

    print('Updated rows: ${result.affectedRows}');
  }

  Future<void> insertGenInfo(String phone, String date, String address, bool status, int id) async {
    var result = await _connection!.execute(
        '''
            INSERT INTO 
            general_info (phone_number, date, address, status, id_student) 
            VALUES (:phone, :date, :address, :status, :id);
         ''',
        {
          'phone': phone,
          'date': date,
          'address': address,
          'status': status,
          'id': id
        }
    );

    print(result.affectedRows);
  }
  Future<void> updateGenInfo(int id, String phoneNumber, String date, String address) async {
    var result = await _connection!.execute(
        ''' 
      UPDATE general_info
      SET
        phone_number = :phone_number,  
        date = :date,          
        address = :address        
      WHERE id = :id;       
      ''',
        {
          'phone_number': phoneNumber,
          'date': date,
          'address': address,
          'id': id
        }
    );

    print('Updated rows: ${result.affectedRows}');
  }

  Future<void> updateEduData(int id, String institutionName, String endDate, String averageScore) async {
    var result = await _connection!.execute(
        ''' 
          UPDATE education_data
          SET
            institution_name = :institution_name,  
            end_date = :end_date,          
            average_score = :average_score        
          WHERE id = :id;       
      ''',
        {
          'institution_name': institutionName,
          'end_date': endDate,
          'average_score': averageScore,
          'id': id
        }
    );

    print('Updated rows: ${result.affectedRows}');
  }
  Future<void> insertEduDate(String endDate, String institutionName, String averageScore, int id) async {
    String? validScore = averageScore.isEmpty ? null : averageScore;

    var result = await _connection!.execute(
        '''
            INSERT INTO 
            education_data (end_date, institution_name, average_score, id_student) 
            VALUES (:end_date, :institution_name, :average_score, :id_student);
         ''',
        {
          'end_date': endDate,
          'institution_name': institutionName,
          'average_score': validScore,
          'id_student': id,
        }
    );

    print(result.affectedRows);
  }

  Future<void> updateArmyServ(int id, String startDate, String endDate, String unit) async {
    var result = await _connection!.execute(
        ''' 
          UPDATE service_in_army
          SET
            start_date = :start_date,  
            end_date = :end_date,          
            unit = :unit        
          WHERE id = :id;       
      ''',
        {
          'start_date': startDate,
          'end_date': endDate,
          'unit': unit,
          'id': id
        }
    );

    print('Updated rows: ${result.affectedRows}');
  }
  Future<void> insertArmyServ(String endDate, String startDate, String unit, int id) async {
    var result = await _connection!.execute(
        '''
            INSERT INTO 
            service_in_army (end_date, start_date, unit, id_student) 
            VALUES (:end_date, :start_date, :unit, :id_student);
         ''',
        {
          'end_date': endDate,
          'start_date': startDate,
          'unit': unit,
          'id_student': id,
        }
    );

    print(result.affectedRows);

  }

  Future<void> updateJobActivity(int id, String startDate, String endDate, String place, String jobPosition, String phoneNumber) async {
    String? validEndDate = endDate.isEmpty ? null : endDate;

    var result = await _connection!.execute(
        ''' 
      UPDATE job_activity
      SET
        start_date = :start_date,  
        end_date = :end_date,          
        place = :place,  -- Added missing comma
        job_position = :job_position,  -- Added missing comma
        phone_number = :phone_number
      WHERE id = :id;       
    ''',
        {
          'start_date': startDate,
          'end_date': validEndDate,
          'place': place,
          'job_position': jobPosition,
          'phone_number': phoneNumber,
          'id': id
        }
    );

    print('Updated rows: ${result.affectedRows}');
  }
  Future<void> insertJobActivity(int id, String startDate, String endDate, String place, String jobPosition, String phoneNumber) async {
    String? validEndDate = endDate.isEmpty ? null : endDate;

    var result = await _connection!.execute(
        '''
            INSERT INTO 
            job_activity (end_date, start_date, phone_number, place, job_position, id_student) 
            VALUES (:end_date, :start_date, :phone_number, :place, :job_position, :id_student);
         ''',
        {
          'end_date': validEndDate,
          'start_date': startDate,
          'phone_number': phoneNumber,
          'place': place,
          'job_position': jobPosition,
          'id_student': id,
        }
    );

    print(result.affectedRows);
  }

  Future<void> updateParentsInfo(int id, String father, String fathersPhone, String mother, String mothersPhone, String note) async {
    var result = await _connection!.execute(
        ''' 
      UPDATE parents_info
      SET
        father = :father,  
        fathers_phone = :fathersPhone,          
        mother = :mother,  
        mothers_phone = :mothersPhone, 
        note = :note
      WHERE id = :id;       
    ''',
        {
          'father': father,
          'fathersPhone': fathersPhone,
          'mother': mother,
          'mothersPhone': mothersPhone,
          'note': note,
          'id': id
        }
    );

    print('Updated rows: ${result.affectedRows}');
  }
  Future<void> insertParentsInfo(int id, String father, String fathersPhone, String mother, String mothersPhone, String note) async {
    var result = await _connection!.execute(
        '''
            INSERT INTO 
            parents_info (father, fathers_phone, mother, mothers_phone, note, id_student) 
            VALUES (:father, :fathers_phone, :mother, :mothers_phone, :note, :id_student);
         ''',
        {
          'father': father,
          'fathers_phone': fathersPhone,
          'mother': mother,
          'mothers_phone': mothersPhone,
          'note': note,
          'id_student': id,
        }
    );

    print(result.affectedRows);

  }

  Future<void> updateSocialActivity(int id, int session, String date, String activity) async {
    var result = await _connection!.execute(
        ''' 
      UPDATE social_activity
      SET
        session = :session,  
        date = :date,          
        activity = :activity
      WHERE id = :id;       
    ''',
        {
          'session': session,
          'date': date,
          'activity': activity,
          'id': id
        }
    );

    print('Updated rows: ${result.affectedRows}');
  }
  Future<void> insertSocialActivity(int id, int session, String date, String activity) async {
    var result = await _connection!.execute(
        '''
            INSERT INTO 
            social_activity (session, date, activity, id_student) 
            VALUES (:session, :date, :activity, :id_student);
         ''',
        {
          'session': session,
          'date': date,
          'activity': activity,
          'id_student': id,
        }
    );

    print(result.affectedRows);
  }

  Future<void> updateCircleActivity(int id, int session, String circleName, String note) async {
    var result = await _connection!.execute(
        ''' 
      UPDATE circle_activity
      SET
        session = :session,  
        circle_name = :circle_name,          
        note = :note
      WHERE id = :id;       
    ''',
        {
          'session': session,
          'circle_name': circleName,
          'note': note,
          'id': id
        }
    );

    print('Updated rows: ${result.affectedRows}');
  }
  Future<void> insertCircleActivity(int id, int session, String circleName, String note) async {
    var result = await _connection!.execute(
        '''
            INSERT INTO 
            circle_activity (session, circle_name, note, id_student) 
            VALUES (:session, :circle_name, :note, :id_student);
         ''',
        {
          'session': session,
          'circle_name': circleName,
          'note': note,
          'id_student': id,
        }
    );

    print(result.affectedRows);

  }

  Future<void> updateIndividualEscort(int id, int session, String date, String content) async {
    var result = await _connection!.execute(
        ''' 
      UPDATE individual_escort
      SET
        session = :session,  
        date = :date,          
        content = :content
      WHERE id = :id;       
    ''',
        {
          'session': session,
          'date': date,
          'content': content,
          'id': id
        }
    );

    print('Updated rows: ${result.affectedRows}');
  }
  Future<void> insertIndividualEscort(int id, int session, String date, String content) async {
    var result = await _connection!.execute(
        '''
            INSERT INTO 
            individual_escort (session, date, content, id_student) 
            VALUES (:session, :date, :content, :id_student);
         ''',
        {
          'session': session,
          'date': date,
          'content': content,
          'id_student': id,
        }
    );

    print(result.affectedRows);
  }

  Future<void> updateEncouragement(int id, int session, String date, String content) async {
    var result = await _connection!.execute(
        ''' 
      UPDATE encouragement
      SET
        session = :session,  
        date = :date,          
        content = :content
      WHERE id = :id;       
    ''',
        {
          'session': session,
          'date': date,
          'content': content,
          'id': id
        }
    );

    print('Updated rows: ${result.affectedRows}');
  }
  Future<void> insertEncouragement(int id, int session, String date, String content) async {
    var result = await _connection!.execute(
        '''
            INSERT INTO 
            encouragement (session, date, content, id_student) 
            VALUES (:session, :date, :content, :id_student);
         ''',
        {
          'session': session,
          'date': date,
          'content': content,
          'id_student': id,
        }
    );

    print(result.affectedRows);
  }


  Future<void> insertDefaultSp(int idStudent, int idCategory, String startDate, String endDate) async {
    String? validEndDate = endDate.isEmpty ? null : endDate;

    var result = await _connection!.execute(
        '''
            INSERT INTO 
            sp_category (id_student, id_category_name, start_date, end_date) 
            VALUES (:id_student, :id_category, :start_date, :end_date);
         ''',
        {
          'id_student': idStudent,
          'id_category': idCategory,
          'start_date': startDate,
          'end_date': validEndDate,
        }
    );

    print(result.affectedRows);
  }
  Future<void> updateDefaultSp(int id, String startDate, String endDate) async {
    String? validEndDate = endDate.isEmpty ? null : endDate;

    var result = await _connection!.execute(
        ''' 
      UPDATE sp_category
      SET
        start_date = :start_date,
        end_date = :end_date
      WHERE id = :id;       
    ''',
        {
          'start_date': startDate,
          'end_date': validEndDate,
          'id': id
        }
    );

    print('Updated rows: ${result.affectedRows}');
  }


  Future<void> insertInvalidSp(int idStudent, int idCategory, String startDate, String endDate, String invalidGroup) async {

    String? validEndDate = endDate.isEmpty ? null : endDate;

    await _connection!.execute('START TRANSACTION');

    var result = await _connection!.execute(
        '''
      INSERT INTO 
      sp_category (id_student, id_category_name, start_date, end_date) 
      VALUES (:id_student, :id_category, :start_date, :end_date);
      ''',
        {
          'id_student': idStudent,
          'id_category': idCategory,
          'start_date': startDate,
          'end_date': validEndDate,
        }
    );

    BigInt spCategoryId = result.lastInsertID;

    if (spCategoryId  > BigInt.zero) {
      await _connection!.execute(
          '''
        INSERT INTO 
        sp_invalid_people (id_category, invalid_group) 
        VALUES (:id_category, :invalid_group);
        ''',
          {
            'id_category': spCategoryId,
            'invalid_group': invalidGroup,
          }
      );
    }

    await _connection!.execute('COMMIT');

    print('Data inserted successfully into sp_category and sp_invalid_people');
  }
  Future<void> updateInvalidSp(int id, String startDate,  String endDate, String group) async {
    String? validEndDate = endDate.isEmpty ? null : endDate;
    String? validGroup = group.isEmpty ? null : group;
    var result = await _connection!.execute('''
      UPDATE sp_category spc
      JOIN sp_invalid_people spip ON spip.id_category = spc.id
      SET spc.start_date = :start_date,
          spc.end_date = :end_date,
          spip.invalid_group = :group
      WHERE spc.id = :id;
    ''', {
      'id': id,
      'start_date': startDate,
      'end_date': validEndDate,
      'group': validGroup,
    });

    print('Updated rows: ${result.affectedRows}');
  }

  Future<void> insertChornobyltsiSp(int idStudent, int idCategory, String startDate, String endDate, String group) async {

    String? validEndDate = endDate.isEmpty ? null : endDate;

    // Початок транзакції
    await _connection!.transactional((conn) async {
      // Вставка в sp_category
      var result = await conn.execute(
          '''
        INSERT INTO 
        sp_category (id_student, id_category_name, start_date, end_date) 
        VALUES (:id_student, :id_category, :start_date, :end_date);
        ''',
          {
            'id_student': idStudent,
            'id_category': idCategory,
            'start_date': startDate,
            'end_date': validEndDate,
          }
      );

      // Отримання останнього вставленого id
      BigInt categoryId = result.lastInsertID!;

      // Вставка в sp_chornobyltsi з використанням отриманого categoryId
      await conn.execute(
          '''
        INSERT INTO 
        sp_chornobyltsi (id_category, `group`) 
        VALUES (:id_category, :group);
        ''',
          {
            'id_category': categoryId,
            'group': group,
          }
      );

      print('Data successfully inserted into both tables');
    });
  }
  Future<void> updateChornobyltsiSp(int id, String startDate,  String endDate, String group) async {
    String? validEndDate = endDate.isEmpty ? null : endDate;
    String? validGroup = group.isEmpty ? null : group;
    var result = await _connection!.execute('''
      UPDATE sp_category spc
      JOIN sp_chornobyltsi spip ON spip.id_category = spc.id
      SET spc.start_date = :start_date,
          spc.end_date = :end_date,
          spip.`group` = :group
      WHERE spc.id = :id;
    ''', {
      'id': id,
      'start_date': startDate,
      'end_date': validEndDate,
      'group': validGroup,
    });

    print('Updated rows: ${result.affectedRows}');
  }


  Future<void> insertManyChildrenSp(int idStudent, int idCategory, String startDate, String endDate, String numOfChild, String lessThan18, String moreThan18Studying) async {

    String? validEndDate = endDate.isEmpty ? null : endDate;
    String? validLess = lessThan18.isEmpty ? null : lessThan18;
    String? validMore = moreThan18Studying.isEmpty ? null : moreThan18Studying;

// Початок транзакції
    await _connection!.transactional((conn) async {
      // Вставка в sp_category
      var result = await conn.execute(
          '''
        INSERT INTO 
        sp_category (id_student, id_category_name, start_date, end_date) 
        VALUES (:id_student, :id_category, :start_date, :end_date);
        ''',
          {
            'id_student': idStudent,
            'id_category': idCategory,
            'start_date': startDate,
            'end_date': validEndDate,
          }
      );

      // Отримання останнього вставленого id
      BigInt categoryId = result.lastInsertID!;

      // Вставка в sp_chornobyltsi з використанням отриманого categoryId
      await conn.execute(
          '''
        INSERT INTO 
        sp_many_child_family (id_category, number_of_children, less_than_18, more_than_18_studying) 
        VALUES (:id_category, :number_of_children, :less_than_18, :more_than_18_studying);
        ''',
          {
            'id_category': categoryId,
            'number_of_children': numOfChild,
            'less_than_18': validLess,
            'more_than_18_studying': validMore
          }
      );

      print('Data successfully inserted into both tables many childreen ');
    });
  }

  Future<void> updateWorkPlan(int id, int session, String eventName, String executionDate, String executor, bool isDone, bool adminConfirmation) async {
    var result = await _connection!.execute(
        ''' 
      UPDATE work_plan
      SET
        session = :session,  
        event_name = :event_name,
        execution_date = :execution_date,
        executor = :executor,
        isDone = :isDone,
        admin_confirmation = :admin_confirmation
      WHERE id = :id;       
    ''',
        {
          'session': session,
          'event_name': eventName,
          'execution_date': executionDate,
          'executor': executor,
          'isDone': isDone,
          'admin_confirmation': adminConfirmation,
          'id': id
        }
    );

    print('Updated rows: ${result.affectedRows}');
  }
  Future<void> insertWorkPlan(int session, String eventName, String executionDate, String executor, bool isDone, bool adminConfirmation, String creator, String year) async {
    var result = await _connection!.execute(
        '''
            INSERT INTO 
            work_plan (session, event_name, execution_date, executor, isDone, admin_confirmation, creator, year) 
           VALUES (:session, :event_name, :execution_date, :executor, :isDone, :admin_confirmation, :creator, :year);
         ''',
        {
          'session': session,
          'event_name': eventName,
          'execution_date': executionDate,
          'executor': executor,
          'isDone': isDone,
          'admin_confirmation': adminConfirmation,
          'creator': creator,
          'year': year
        }
    );

    print(result.affectedRows);
  }

  Future<void> updatePassword(String email, String password) async {
    var result = await _connection!.execute(
        ''' 
      UPDATE curators
      SET
        password = :password
      WHERE email = :email;       
      ''',
        {
          'password': password,
          'email': email
        }
    );

    print('Updated rows: ${result.affectedRows}');
  }

  Future<void> insertGroupName(String groupName) async {
    var result = await _connection!.execute(
        '''
            INSERT INTO 
            `groups` (group_name, isGrad)
            VALUES (:group_name, 0);
         ''',
        {
          'group_name': groupName
        }
    );

    print(result.affectedRows);

  }

  Future<void> insertCategoryName(String categoryName) async {
    var result = await _connection!.execute(
        '''
            INSERT INTO 
            `sp_category_name` (category) 
            VALUES (:category);
         ''',
        {
          'category': categoryName
        }
    );

    print(result.affectedRows);

  }

  Future<void> updateStudentStatus(int id) async {
    var result = await _connection!.execute(
        ''' 
      UPDATE students
      SET
        status = 1
      WHERE id = $id;       
    ''');

    print('Updated rows: ${result.affectedRows}');
  }
  Future<void> updateGroupStatus(int id) async {
    var result = await _connection!.execute(
        ''' 
      UPDATE `groups`
      SET
        isGrad = 1
      WHERE id = $id;       
    ''');

    print('Updated rows: ${result.affectedRows}');
  }

  Future<void> updateWPDoneStatus(int id) async {
    var result = await _connection!.execute(
        ''' 
      UPDATE work_plan
      SET
        isDone = 1
      WHERE id = $id;       
    ''');

    print('Updated rows: ${result.affectedRows}');
  }




  Future<void> removeRow(String table, int id) async {
    var result = await _connection!.execute(
        ''' delete from $table where id = $id;''');

    print('Deleted rows: ${result.affectedRows}');
  }

  Future<void> removeSPCategory(String cat) async {
    var result = await _connection!.execute(
        ''' delete from sp_category_name where category like '$cat';''');

    print('Deleted rows: ${result.affectedRows}');
  }




  Future<void> close() async {
    if (_connection != null) {
      await _connection!.close();
      print('Connection closed.');
    }
  }
}

