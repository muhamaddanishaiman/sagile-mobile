import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_story_controller.dart';
import 'nfr_model.dart';

class UserStoryPage extends StatelessWidget {
  final int userStoryId;

  const UserStoryPage({Key? key, required this.userStoryId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserStoryController(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Story Details'),
        ),
        body: Consumer<UserStoryController>(
          builder: (context, controller, child) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'User Story Info',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text('User Story ID: 1'),
                  const Text('Description: As a user...'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      controller.getLinkedNFR(userStoryId);
                    },
                    child: const Text('View Linked NFR'),
                  ),
                  const SizedBox(height: 20),
                  if (controller.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (controller.errorMessage != null)
                     Text('Error: ${controller.errorMessage}', style: const TextStyle(color: Colors.red))
                  else if (controller.linkedNFRs.isEmpty && controller.hasFetched)
                     const Padding(
                       padding: EdgeInsets.only(top: 20),
                       child: Text('No linked Non-Functional Requirements found.',
                         style: TextStyle(fontStyle: FontStyle.italic)),
                     )
                  else if (!controller.hasFetched)
                     const SizedBox.shrink()
                  else
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Linked Non-Functional Requirements:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              itemCount: controller.linkedNFRs.length,
                              itemBuilder: (context, index) {
                                final nfr = controller.linkedNFRs[index];
                                return Card(
                                  child: ListTile(
                                    title: Text(nfr.title),
                                    subtitle: Text('${nfr.type}: ${nfr.description}'),
                                    leading: Icon(
                                      nfr.type == 'Performance' 
                                      ? Icons.speed 
                                      : Icons.security
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
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
