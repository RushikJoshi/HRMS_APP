import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../utils/app_colors.dart';

class OrgNode {
  final String id;
  final String name;
  final String designation;
  final String avatar;
  final Color color;
  final List<OrgNode> children;

  OrgNode({
    required this.id,
    required this.name,
    required this.designation,
    required this.avatar,
    required this.color,
    this.children = const [],
  });
}

class OrgStructureScreen extends StatelessWidget {
  const OrgStructureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _OrgStructureScreenContent();
  }
}

class _OrgStructureScreenContent extends StatefulWidget {
  const _OrgStructureScreenContent();

  @override
  State<_OrgStructureScreenContent> createState() =>
      _OrgStructureScreenContentState();
}

class _OrgStructureScreenContentState
    extends State<_OrgStructureScreenContent> {
  late OrgNode _rootNode;
  final List<OrgNode> _navStack = [];

  @override
  void initState() {
    super.initState();
    _rootNode = _generateMockData();
    _navStack.add(_rootNode);
  }

  OrgNode get _currentNode => _navStack.last;

  void _pushNode(OrgNode node) {
    setState(() {
      _navStack.add(node);
    });
  }

  void _popNode() {
    if (_navStack.length > 1) {
      setState(() {
        _navStack.removeLast();
      });
    }
  }

  void _popToNode(OrgNode node) {
    final index = _navStack.indexOf(node);
    if (index != -1) {
      setState(() {
        _navStack.removeRange(index + 1, _navStack.length);
      });
    }
  }

  OrgNode _generateMockData() {
    List<OrgNode> generateTeam(
      String prefix,
      int count,
      Color color,
      String role,
    ) {
      return List.generate(count, (index) {
        return OrgNode(
          id: '${prefix}_$index',
          name: '$role ${index + 1}',
          designation: role,
          avatar: '${prefix[0]}${index + 1}',
          color: color,
        );
      });
    }

    return OrgNode(
      id: 'CEO',
      name: 'Rajesh Kumar',
      designation: 'Chief Executive Officer',
      avatar: 'RK',
      color: Colors.purple,
      children: [
        OrgNode(
          id: 'CTO',
          name: 'Priya Sharma',
          designation: 'Chief Technology Officer',
          avatar: 'PS',
          color: Colors.blue,
          children: [
            OrgNode(
              id: 'EM1',
              name: 'Amit Patel',
              designation: 'Engineering Manager',
              avatar: 'AP',
              color: Colors.teal,
              children: [
                ...generateTeam('DEV', 5, Colors.orange, 'Senior Developer'),
                OrgNode(
                  id: 'TL1',
                  name: 'Sneha Mehta',
                  designation: 'Team Lead',
                  avatar: 'SM',
                  color: Colors.indigo,
                  children: generateTeam(
                    'JD',
                    3,
                    Colors.cyan,
                    'Junior Developer',
                  ),
                ),
              ],
            ),
            OrgNode(
              id: 'EM2',
              name: 'Kavita Desai',
              designation: 'Product Manager',
              avatar: 'KD',
              color: Colors.green,
              children: generateTeam('PM', 4, Colors.pink, 'Product Manager'),
            ),
          ],
        ),
        OrgNode(
          id: 'CFO',
          name: 'Vikram Joshi',
          designation: 'Chief Financial Officer',
          avatar: 'VJ',
          color: Colors.red,
          children: [
            OrgNode(
              id: 'ACC',
              name: 'Anjali Shah',
              designation: 'Accounts Manager',
              avatar: 'AS',
              color: Colors.brown,
              children: generateTeam('ACC', 3, Colors.blueGrey, 'Accountant'),
            ),
          ],
        ),
        OrgNode(
          id: 'HR',
          name: 'Meera Nair',
          designation: 'HR Director',
          avatar: 'MN',
          color: Colors.pink,
          children: [
            OrgNode(
              id: 'HRM',
              name: 'Arjun Reddy',
              designation: 'HR Manager',
              avatar: 'AR',
              color: Colors.deepPurple,
              children: generateTeam(
                'HR',
                2,
                Colors.purpleAccent,
                'HR Executive',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatar(OrgNode node, double radius) {
    return CircleAvatar(
      backgroundColor: node.color.withOpacity(0.1),
      radius: radius,
      child: Text(
        node.avatar,
        style: TextStyle(
          color: node.color,
          fontWeight: FontWeight.bold,
          fontSize: (radius * 0.55),
        ),
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    return Container(
      height: 12.w,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _navStack.length,
        separatorBuilder: (context, index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Icon(Icons.chevron_right, size: 4.5.w, color: Colors.grey),
        ),
        itemBuilder: (context, index) {
          final node = _navStack[index];
          final isLast = index == _navStack.length - 1;
          return InkWell(
            onTap: isLast ? null : () => _popToNode(node),
            child: Center(
              child: Text(
                node.name,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                  color: isLast ? AppColors.primary : Colors.grey.shade700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildManagerCard(OrgNode manager) {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [manager.color, manager.color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: manager.color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(0.5.w),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: _buildAvatar(manager, 8.w),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT MANAGER',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 8.sp,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.w),
                Text(
                  manager.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 0.5.w),
                Text(
                  manager.designation,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberCard(OrgNode member) {
    final hasChildren = member.children.isNotEmpty;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: hasChildren ? () => _pushNode(member) : null,
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              children: [
                _buildAvatar(member, 6.w),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 0.5.w),
                      Text(
                        member.designation,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (hasChildren) ...[
                        SizedBox(height: 1.w),
                        Text(
                          '${member.children.length} Team Members',
                          style: TextStyle(
                            fontSize: 8.5.sp,
                            color: member.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (hasChildren)
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: member.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 4.w,
                      color: member.color,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_navStack.length > 1) {
          _popNode();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('Org Structure'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          leading: _navStack.length > 1
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _popNode,
                )
              : null,
        ),
        body: Column(
          children: [
            if (_navStack.length > 1) _buildBreadcrumbs(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: 10.w),
                children: [
                  _buildManagerCard(_currentNode),

                  if (_currentNode.children.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 2.w,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'DIRECT REPORTS',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ..._currentNode.children.map(
                      (child) => _buildTeamMemberCard(child),
                    ),
                  ] else ...[
                    SizedBox(height: 10.w),
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.group_off_outlined,
                            size: 15.w,
                            color: Colors.grey.shade300,
                          ),
                          SizedBox(height: 3.w),
                          Text(
                            'No Direct Reports',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
