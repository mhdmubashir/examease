import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../presentation/auth_bloc.dart';
import '../../../core/widgets/helper/responsive.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontSize: Responsive.s(18))),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              context.go('/login');
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state.user;
          if (user == null) {
            return Center(
              child: Text(
                'No user profile found.',
                style: TextStyle(fontSize: Responsive.s(16)),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AuthBloc>().add(AuthCheckRequested());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(Responsive.s(16.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: Responsive.s(50),
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: Responsive.s(40),
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.s(24)),
                  _buildInfoTile(context, 'Name', user.name, Icons.person),
                  _buildInfoTile(context, 'Email', user.email, Icons.email),
                  _buildInfoTile(
                    context,
                    'Role',
                    user.role.toUpperCase(),
                    Icons.verified_user,
                  ),
                  SizedBox(height: Responsive.s(32)),
                  Text(
                    'Purchased Modules',
                    style: TextStyle(
                      fontSize: Responsive.s(20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.s(16)),
                  if (user.purchasedItems.isEmpty)
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Responsive.s(12)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(Responsive.s(16.0)),
                        child: Text(
                          'You haven\'t purchased any modules yet.',
                          style: TextStyle(fontSize: Responsive.s(14)),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: user.purchasedItems.length,
                      itemBuilder: (context, index) {
                        final itemId = user.purchasedItems[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: Responsive.s(8)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              Responsive.s(12),
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.shopping_bag,
                              color: Colors.green,
                              size: Responsive.s(24),
                            ),
                            title: Text(
                              'Module ID: $itemId',
                              style: TextStyle(
                                fontSize: Responsive.s(14),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Lifetime Access',
                              style: TextStyle(fontSize: Responsive.s(12)),
                            ),
                            trailing: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: Responsive.s(20),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.s(16.0)),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: Responsive.s(22),
          ),
          SizedBox(width: Responsive.s(16)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: Responsive.s(12),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: Responsive.s(16),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
