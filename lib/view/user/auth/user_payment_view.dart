import 'package:flutter/material.dart';

class UserPaymentView extends StatefulWidget {
  const UserPaymentView({super.key});

  @override
  State<UserPaymentView> createState() => _UserPaymentViewState();
}

class _UserPaymentViewState extends State<UserPaymentView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back),
        title: Text('주소/결제방법'),
        centerTitle: true,
      ),

      body: Center(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 60),
            Text(
              '수령지점(자치구)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            DropdownButton(
              dropdownColor: Colors.white,
              //Theme.of(context).colorScheme.primaryContainer,
              iconEnabledColor: Colors.black,
              //Theme.of(context).colorScheme.error,
              value: '강남구',
              icon: Icon(Icons.keyboard_arrow_down),
              items: ['강남구', '서초구', '송파구'].map((String value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.black,
                      //Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                //dropDownValue = value!;
                //imageName = value;
                setState(() {});
              },
            ),

            SizedBox(height: 60),
            Text(
              '결제수단',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            DropdownButton(
              dropdownColor: Colors.white,
              //Theme.of(context).colorScheme.primaryContainer,
              iconEnabledColor: Colors.black,
              //Theme.of(context).colorScheme.error,
              value: '카카오페이',
              icon: Icon(Icons.keyboard_arrow_down),
              items: ['카카오페이', '카드결제', '계좌이체'].map((String value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.black,
                      //Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                //dropDownValue = value!;
                //imageName = value;
                setState(() {});
              },
            ),
            SizedBox(height: 80),
            //ElevatedButton(onPressed: null, child: Text('변경')),
          ],
        ),
      ),
    );
  }
}
