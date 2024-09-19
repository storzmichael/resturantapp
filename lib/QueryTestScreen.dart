import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QueryTestScreen extends StatefulWidget {
  QueryTestScreen({super.key});

  @override
  State<QueryTestScreen> createState() => _QueryTestScreenState();
}

class _QueryTestScreenState extends State<QueryTestScreen> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Rating Dropdown
  int? selectedRating;

  // für PLZ-Eingabe
  final plzController = TextEditingController();

  // Ergebnisse der Abfrage
  List<QueryDocumentSnapshot>? filteredRestaurants;

  // Firestore-Abfragen Rating und PLZ
  Future<void> filterByRating(int rating) async {
    final querySnapshot = await _firestore.collection('Restaurants').where('Rating', isEqualTo: rating).get();

    setState(() {
      filteredRestaurants = querySnapshot.docs;
    });
  }

  Future<void> filterByPLZ(String plz) async {
    final querySnapshot = await _firestore.collection('Restaurants').where('PLZ', isEqualTo: plz).get();

    setState(() {
      filteredRestaurants = querySnapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Query Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Dropdown für Rating
            DropdownButton<int?>(
              value: selectedRating,
              hint: Text('Filter nach Rating'),
              onChanged: (int? rating) {
                setState(() {
                  selectedRating = rating;
                });
                filterByRating(rating!);
              },
              items: [1, 2, 3, 4, 5].map((int rating) {
                return DropdownMenuItem<int?>(
                  value: rating,
                  child: Text('Rating: $rating'),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            //Eingabe für PLZ
            TextField(
              controller: plzController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Filter nach PLZ',
                suffixIcon: IconButton(
                  onPressed: () {
                    filterByPLZ(plzController.text);
                  },
                  icon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 16),

            //Ergebnisse der Abfrage
            Expanded(
              child: filteredRestaurants == null
                  ? const Center(child: Text('Bitte eine Filteroption auswählen'))
                  : ListView.builder(
                      itemCount: filteredRestaurants?.length ?? 0,
                      itemBuilder: (context, index) {
                        final restaurantData = filteredRestaurants![index].data() as Map<String, dynamic>;

                        return ListTile(
                          title: Text(restaurantData['Name'] ?? 'Unbekannt'),
                          subtitle: Text('PLZ: ${restaurantData['PLZ']?.toString() ?? 'Unbekannt'}'),
                          trailing: Text('Rating: ${restaurantData['Rating']?.toString() ?? 'Unbekannt'}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
