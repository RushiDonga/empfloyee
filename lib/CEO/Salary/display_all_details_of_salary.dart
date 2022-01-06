import 'package:flutter/material.dart';

class DisplayAllDetailsOfSalary extends StatefulWidget {
  @override
  _DisplayAllDetailsOfSalaryState createState() => _DisplayAllDetailsOfSalaryState();

  DisplayAllDetailsOfSalary({this.name, this.companyName, this.salary, this.month, this.paymentDate, this.paidAmount, this.gst});
  final String companyName;
  final String name;
  final String salary;
  final String month;
  final String paymentDate;
  final String paidAmount;
  final String gst;
}

class _DisplayAllDetailsOfSalaryState extends State<DisplayAllDetailsOfSalary> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Card(
            elevation: 5.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 50.0,
                      ),
                      Text(
                        "🔅",
                        style: TextStyle(
                          fontSize: 30.0
                        ),
                      ),
                      Text(
                        widget.companyName,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5
                        ),
                      )
                    ],
                  ),

                  DataTable(
                    columns: [
                      DataColumn(label: Text("")),
                      DataColumn(label: Text("")),
                    ],
                    rows: [
                      DataRow(cells: [
                        DataCell(Text("Employee Name")),
                        DataCell(Text(widget.name)),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("Month")),
                        DataCell(Text(widget.month)),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("Payment Date")),
                        DataCell(Text(widget.paymentDate == null ? "Not yet Paid" : widget.paymentDate)),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("Salary")),
                        DataCell(Text(widget.salary)),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("GST")),
                        DataCell(Text(widget.gst + " %")),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("Total Leaves")),
                        DataCell(Text("15")),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("Total Amount")),
                        DataCell(Text(widget.paidAmount)),
                      ]),
                    ],
                  ),

                  SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
