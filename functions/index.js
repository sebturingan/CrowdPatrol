const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

var msgData;
const db = admin.firestore();
const fcm = admin.messaging();

exports.newSubscriberNotification = functions.firestore
    .document('posts/{postsId}')
    .onCreate((snap, context) => {
        msgData = snap.data();
        admin.firestore().collection('devicetokens').get().then((snap) => {
            var tokens = [];
            if (snap.empty) {
                console.log('No Device');
            } else {
                for (var token of snap.docs) {
                    tokens.push(token.data().devtoken);
                }
                var payload = {
                    "notification": {
                        "title": "From " + msgData.sender,
                        "body": msgData.details,
                        "sound": "default"
                    },
                    "data": {
                        "sender": msgData.sender,
                        "message": msgData.details
                    }
                }
                return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                    console.log('Pushed them all');
                }).catch((err) => {
                    console.log(err);
                });
            }
        });
    });

exports.sendToTopic = functions.firestore
    .document('posts/{postsID}')
    .onUpdate((change, context) => {
        const post = change.after.data();

        const payload = {
            notification: {
            title: post.sender,
            body: 'Your post has been responded to.'
            }
        };

        return fcm.sendToTopic('items', payload);
    });