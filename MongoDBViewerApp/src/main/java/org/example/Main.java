package org.example;

import org.bson.Document;

import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.MongoCollection;

import java.util.ArrayList;
import java.util.List;

public class Main {
    public static void main(String[] args) {
        // Connection string to connect to MongoDB container
        String uri = "mongodb://mongodb1:27017/?directConnection=true&serverSelectionTimeoutMS=2000"; // Adjust if necessary

        // Create a MongoClient instance
        try (MongoClient mongoClient = MongoClients.create(uri)) {

            // Connect to the "somedb" database
            MongoDatabase database = mongoClient.getDatabase("somedb");

            System.out.println("Successfully connected to MongoDB!");

            System.out.println("database name = " + database.getName());

            List<Document> databases = mongoClient.listDatabases().into(new ArrayList<>());
            databases.forEach(db -> System.out.println(db.toJson()));

            // Get the "helloDoc" collection
            MongoCollection<Document> collection = database.getCollection("helloDoc");
            System.out.println("is ok to get collection");

            // Print all documents in the collection
            for (Document doc : collection.find()) {
                System.out.println(doc.toJson());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}