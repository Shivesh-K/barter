import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { DocumentSnapshot } from 'firebase-functions/lib/providers/firestore';

admin.initializeApp();

enum RequestStatus {
    WAITING, ACCEPTED, REJECTED
}

export const acceptRequest = functions.firestore
    .document('/requests/{id}')
    .onUpdate(async (change, context) => {
        const firestore = admin.firestore();

        const data = change.after.data();

        if (data['status'] === RequestStatus.ACCEPTED) {
            const c1 = await firestore
                .collection('requests')
                .where('for.id', '==', data['for']['id'])
                .get();
            const c2 = await firestore
                .collection('requests')
                .where('for.id', '==', data['against']['id'])
                .get();
            // Merge both the collections
            c1.docs.push(...c2.docs);

            // Filter out the document which was originally updated
            const docs = c1.docs.filter(doc => {
                console.log({ some: doc.data()['id'], curr: data['id'] });
                return doc.data()['id'] != data['id']
            });

            const batch = firestore.batch();

            // Update all the other requests to be rejected.
            docs.forEach(doc => batch.update(doc.ref, { 'status': RequestStatus.REJECTED }));

            // Get the snapshots of both the barts.
            const [snap1, snap2] = (await Promise.all([
                data['for']['ref'].get(),
                data['against']['ref'].get()
            ])) as [DocumentSnapshot, DocumentSnapshot];

            // Creating the id of the new barter document
            const id: string = snap1.id < snap2.id ? `${snap1.id}-${snap2.id}` : `${snap2.id}-${snap1.id}`;
            batch.set(firestore.collection('barters').doc(id), {
                id,
                first: {
                    id: snap1.id,
                    ref: snap1.ref,
                    authorId: snap1.data()!['author']['uid']
                },
                second: {
                    id: snap2.id,
                    ref: snap2.ref,
                    authorId: snap2.data()!['author']['uid']
                }
            });
            await batch.commit();
        }
    });

export const bartDeleted = functions.firestore
    .document('/barts/{bartId}')
    .onDelete(async (snapshot, context) => {
        const firestore = admin.firestore();
        const batch = firestore.batch();
        const requests = await firestore.collection('requests').where('for.id', '==', snapshot.id).get();
        try {
            requests.docs.forEach(doc => batch.update(doc.ref, { 'status': RequestStatus.REJECTED }));
            await batch.commit();
        } catch (e) {
            console.log("There was some error!");
        }
    });

export const messageSent = functions.firestore
    .document('/chats/{chatId}/messages/{messageId}')
    .onCreate(async (snapshot, context) =>
        await admin.firestore()
            .doc(`/chats/${context.params.chatId}`)
            .set({
                lastMessage: {
                    text: snapshot.get('text'),
                    senderId: snapshot.get('senderId')
                }
            }, { merge: true })
    );
