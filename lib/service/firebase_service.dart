import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uispeed_grocery_shop/page/LoginScreen.dart';

class AuthService {
  // Membuat singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method untuk mendapatkan pengguna yang sedang masuk
  Future<User?> getCurrentUser() async {
    User? loggedInUser;
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print("User is logged in: ${user.email}");
      } else {
        print("No user is logged in.");
      }
    } catch (e) {
      print("Error getting current user: $e");
    }
    return loggedInUser;
  }
}

Future<void> createDocument(String collectionName, String documentName,
    Map<String, dynamic> data) async {
  try {
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(documentName)
        .set(data);
    print("Dokumen berhasil dibuat!");
  } catch (e) {
    print("Error menambahkan dokumen: $e");
  }
}

Future<bool> checkDocumentExists(
    String collectionName, String documentName) async {
  try {
    DocumentSnapshot docSnap = await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(documentName)
        .get();

    if (docSnap.exists) {
      print("Dokumen ada: ${docSnap.data()}");
      return true;
    } else {
      print("Dokumen tidak ada!");
      return false;
    }
  } catch (e) {
    print("Error mengecek dokumen: $e");
    return false;
  }
}

Future<void> readDocument(String collectionName, String documentName) async {
  try {
    DocumentSnapshot docSnap = await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(documentName)
        .get();

    if (docSnap.exists) {
      print("Data dokumen: ${docSnap.data()}");
    } else {
      print("Tidak ada dokumen!");
    }
  } catch (e) {
    print("Error membaca dokumen: $e");
  }
}

Future<dynamic> getProperty(
    String collection, String docId, String property) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  try {
    DocumentSnapshot docSnapshot =
        await firestore.collection(collection).doc(docId).get();
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      if (data.containsKey(property)) {
        return data[property];
      } else {
        print("$property does not exist in the document.");
      }
    } else {
      print("Document does not exist.");
    }
  } catch (e) {
    print("Error getting document: $e");
  }
  return null;
}

Future<void> updateProperty(
  String collection,
  String docId,
  String property,
  dynamic value,
) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    DocumentReference docRef = firestore.collection(collection).doc(docId);
    await docRef.set(
      {property: value},
      SetOptions(
          merge:
              true), // Menggunakan merge untuk menambahkan atau memperbarui properti tanpa menghapus properti lain yang ada
    );
    print("Property added/updated successfully.");
  } catch (e) {
    print("Error adding/updating property: $e");
  }
}

Future<void> checkAndHandleDocument(String collectionName, String documentName,
    Map<String, dynamic> data) async {
  bool exists = await checkDocumentExists(collectionName, documentName);

  if (exists) {
    await readDocument(collectionName, documentName);
  } else {
    await createDocument(collectionName, documentName, data);
  }
}

Future<void> logOut(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    // Redirect to login page or another appropriate action
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  } catch (e) {
    print("Error logging out: $e");
  }
}

Future<void> uploadImage(
    String collection, String docId, String property) async {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    File file = File(pickedFile.path);
    try {
      // Unggah gambar ke Firebase Storage
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = storage.ref().child('images/$fileName');
      UploadTask uploadTask = storageRef.putFile(file);

      // Tunggu sampai pengunggahan selesai dan dapatkan URL unduhan
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      // Simpan URL gambar di Firestore
      await updateProperty(collection, docId, property, downloadURL);

      print("Image uploaded successfully: $downloadURL");
    } catch (e) {
      print("Error uploading image: $e");
    }
  } else {
    print("No image selected");
  }
}

Image networkImage(String imageURL, double width, double height) {
  return Image.network(imageURL,
      width: width,
      height: height,
      fit: BoxFit.cover, loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) {
      return child;
    } else {
      return Center(
        child: CircularProgressIndicator(
          color: const Color(0xFF00541A),
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  (loadingProgress.expectedTotalBytes ?? 1)
              : null,
        ),
      );
    }
  }, errorBuilder:
          (BuildContext context, Object exception, StackTrace? stackTrace) {
    return const Text('Failed to load image');
  });
}

Widget documentStreamBuilder(String collection,
    Widget Function(Map<String, dynamic>) documentCardBuilder) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection(collection).snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (!snapshot.hasData) {
        return const Center(child: Text('No Data Found'));
      }

      final documents = snapshot.data!.docs;

      return ListView.builder(
        itemCount: documents.length,
        itemBuilder: (context, index) {
          final data = documents[index].data() as Map<String, dynamic>;
          return documentCardBuilder(data);
        },
      );
    },
  );
}

Future<void> addToCart(
    String productId, String productName, User currentUser) async {
  // Ambil dokumen keranjang pengguna dari Firestore
  DocumentSnapshot cartDoc = await FirebaseFirestore.instance
      .collection('carts')
      .doc(currentUser.uid)
      .get();

  // Periksa apakah keranjang pengguna sudah ada atau belum
  if (cartDoc.exists) {
    // Periksa apakah produk sudah ada di keranjang
    List<Map<String, dynamic>> cartItems = List.from(cartDoc['cart']);
    bool productExists = false;
    for (int i = 0; i < cartItems.length; i++) {
      if (cartItems[i]['productId'] == productId) {
        // Jika produk sudah ada, tambahkan 1 ke quantity
        cartItems[i]['quantity'] = cartItems[i]['quantity'] + 1;
        productExists = true;
        break;
      }
    }

    // Jika produk belum ada, tambahkan produk baru dengan quantity 1
    if (!productExists) {
      cartItems.add({
        'productId': productId,
        'productName': productName,
        'quantity': 1,
      });
    }

    // Perbarui dokumen keranjang dengan item-item baru
    await FirebaseFirestore.instance
        .collection('carts')
        .doc(currentUser.uid)
        .update({'cart': cartItems});
  } else {
    // Jika belum ada, buat dokumen keranjang baru
    await FirebaseFirestore.instance
        .collection('carts')
        .doc(currentUser.uid)
        .set({
      'cart': [
        {
          'productId': productId,
          'productName': productName,
          'quantity': 1,
        }
      ]
    });
  }
}

Future<void> removeFromCart(String productId, User currentUser) async {
  // Ambil dokumen keranjang pengguna dari Firestore
  DocumentSnapshot cartDoc = await FirebaseFirestore.instance
      .collection('carts')
      .doc(currentUser.uid)
      .get();

  // Periksa apakah keranjang pengguna sudah ada atau belum
  if (cartDoc.exists) {
    // Ambil item-item dalam keranjang
    List<Map<String, dynamic>> cartItems = List.from(cartDoc['cart']);
    bool productExists = false;

    // Periksa apakah produk ada di keranjang
    for (int i = 0; i < cartItems.length; i++) {
      if (cartItems[i]['productId'] == productId) {
        if (cartItems[i]['quantity'] > 1) {
          // Jika kuantitas lebih dari 1, kurangi kuantitasnya
          cartItems[i]['quantity'] = cartItems[i]['quantity'] - 1;
        } else {
          // Jika kuantitasnya 1, hapus item dari keranjang
          cartItems.removeAt(i);
        }
        productExists = true;
        break;
      }
    }

    if (productExists) {
      // Perbarui dokumen keranjang dengan item-item baru
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(currentUser.uid)
          .update({'cart': cartItems});
    }
  } else {
    // Jika belum ada, bisa abaikan atau lakukan penanganan lainnya
    print("Keranjang tidak ditemukan.");
  }
}

Future<void> removeItemFromCart(String productId, User currentUser) async {
  // Ambil dokumen keranjang pengguna dari Firestore
  DocumentSnapshot cartDoc = await FirebaseFirestore.instance
      .collection('carts')
      .doc(currentUser.uid)
      .get();

  // Periksa apakah keranjang pengguna sudah ada atau belum
  if (cartDoc.exists) {
    // Ambil item-item dalam keranjang
    List<Map<String, dynamic>> cartItems = List.from(cartDoc['cart']);
    bool productExists = false;

    // Periksa apakah produk ada di keranjang
    for (int i = 0; i < cartItems.length; i++) {
      if (cartItems[i]['productId'] == productId) {
        // Hapus item dari keranjang
        cartItems.removeAt(i);
        productExists = true;
        break;
      }
    }

    if (productExists) {
      // Perbarui dokumen keranjang dengan item-item baru
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(currentUser.uid)
          .update({'cart': cartItems});
    }
  } else {
    // Jika belum ada, bisa abaikan atau lakukan penanganan lainnya
    print("Keranjang tidak ditemukan.");
  }
}
