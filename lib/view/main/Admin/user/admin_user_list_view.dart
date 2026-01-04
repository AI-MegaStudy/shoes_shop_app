import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/custom/external_util/network/custom_network_util.dart';
import 'package:shoes_shop_app/model/user.dart';
import 'package:shoes_shop_app/view/main/config/main_ui_config.dart';
import 'package:shoes_shop_app/theme/app_colors.dart';

/// 관리자 사용자 관리 페이지
/// 사용자 리스트를 카드 형태로 표시하고, 소셜/로컬 로그인 구분을 표시합니다.
class AdminUserListView extends StatefulWidget {
  const AdminUserListView({super.key});

  @override
  State<AdminUserListView> createState() => _AdminUserListViewState();
}

class _AdminUserListViewState extends State<AdminUserListView> {
  List<UserWithAuth> _users = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    CustomNetworkUtil.setBaseUrl(config.getApiBaseUrl());
    _loadUsers();
  }

  /// 사용자 목록 로드
  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. 사용자 목록 조회
      final usersResponse = await CustomNetworkUtil.get<Map<String, dynamic>>(
        '/api/users',
        fromJson: (json) => json,
      );

      if (!usersResponse.success || usersResponse.data == null) {
        setState(() {
          _errorMessage = '사용자 목록을 불러올 수 없습니다: ${usersResponse.error}';
          _isLoading = false;
        });
        return;
      }

      final usersList = usersResponse.data!['results'] as List<dynamic>;
      
      // 2. 각 사용자별 인증 정보 조회
      final List<UserWithAuth> usersWithAuth = [];
      
      for (var userData in usersList) {
        final user = User(
          uSeq: userData['u_seq'] as int?,
          uEmail: userData['u_email'] as String,
          uName: userData['u_name'] as String,
          uPhone: userData['u_phone'] as String?,
          uAddress: userData['u_address'] as String?,
          createdAt: userData['created_at'] as String?,
          uQuitDate: userData['u_quit_date'] as String?,
        );

        if (user.uSeq != null) {
          // 사용자별 인증 정보 조회
          final authResponse = await CustomNetworkUtil.get<Map<String, dynamic>>(
            '/api/user_auth_identities/user/${user.uSeq}',
            fromJson: (json) => json,
          );

          List<AuthProviderInfo> authProviders = [];
          String? lastLoginAt;
          
          if (authResponse.success && authResponse.data != null) {
            final authList = authResponse.data!['results'] as List<dynamic>;
            authProviders = authList.map<AuthProviderInfo>((auth) {
              final provider = auth['provider'] as String;
              final providerName = provider == 'local' ? '로컬' : provider.toUpperCase();
              return AuthProviderInfo(
                provider: provider,
                displayName: providerName,
              );
            }).toList();
            
            // 가장 최근 접속일 찾기
            DateTime? latestLogin;
            for (var auth in authList) {
              final loginAt = auth['last_login_at'] as String?;
              if (loginAt != null && loginAt.isNotEmpty) {
                try {
                  final loginDate = DateTime.parse(loginAt);
                  if (latestLogin == null || loginDate.isAfter(latestLogin)) {
                    latestLogin = loginDate;
                    lastLoginAt = loginAt;
                  }
                } catch (e) {
                  // 파싱 에러 무시
                }
              }
            }
          }

          usersWithAuth.add(UserWithAuth(
            user: user,
            authProviders: authProviders,
            lastLoginAt: lastLoginAt,
          ));
        }
      }

      setState(() {
        _users = usersWithAuth;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '오류가 발생했습니다: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final p = context.palette;
        return Scaffold(
          backgroundColor: p.background,
          appBar: AppBar(
            title: Text(
              '고객 관리',
              style: mainAppBarTitleStyle.copyWith(color: p.textPrimary),
            ),
            centerTitle: mainAppBarCenterTitle,
            backgroundColor: p.background,
            foregroundColor: p.textPrimary,
          ),
          body: SafeArea(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: p.primary),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: p.textSecondary),
                            SizedBox(height: mainDefaultSpacing),
                            Text(
                              _errorMessage!,
                              style: mainBodyTextStyle.copyWith(color: p.textPrimary),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: mainDefaultSpacing),
                            ElevatedButton(
                              onPressed: _loadUsers,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: p.primary,
                                foregroundColor: p.textOnPrimary,
                              ),
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      )
                    : _users.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline, size: 64, color: p.textSecondary),
                                SizedBox(height: mainDefaultSpacing),
                                Text(
                                  '등록된 고객이 없습니다',
                                  style: mainBodyTextStyle.copyWith(color: p.textPrimary),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadUsers,
                            color: p.primary,
                            child: ListView.builder(
                              padding: mainDefaultPadding,
                              itemCount: _users.length,
                              itemBuilder: (context, index) {
                                return _buildUserCard(_users[index], p);
                              },
                            ),
                          ),
          ),
        );
      },
    );
  }

  /// 사용자 카드 빌드
  Widget _buildUserCard(UserWithAuth userWithAuth, AppColorScheme p) {
    final user = userWithAuth.user;
    final authProviders = userWithAuth.authProviders;
    final lastLoginAt = userWithAuth.lastLoginAt;
    
    // 사용자 상태 계산
    final userStatus = _getUserStatus(user, lastLoginAt);
    
    return Card(
      elevation: mainCardElevation,
      color: p.cardBackground,
      margin: const EdgeInsets.only(bottom: mainDefaultSpacing),
      shape: RoundedRectangleBorder(
        borderRadius: mainDefaultBorderRadius,
      ),
      child: Padding(
        padding: mainDefaultPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 이미지
            _buildProfileImage(user.uSeq, p),
            SizedBox(width: mainDefaultSpacing),
            // 사용자 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이름과 상태
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.uName,
                          style: mainTitleStyle.copyWith(color: p.textPrimary),
                        ),
                      ),
                      _buildUserStatusBadge(userStatus, p),
                    ],
                  ),
                  SizedBox(height: mainSmallSpacing),
                  // 이메일
                  Text(
                    user.uEmail,
                    style: mainBodyTextStyle.copyWith(color: p.textSecondary),
                  ),
                  if (user.uPhone != null && user.uPhone!.isNotEmpty) ...[
                    SizedBox(height: mainSmallSpacing),
                    Text(
                      user.uPhone!,
                      style: mainBodyTextStyle.copyWith(color: p.textSecondary),
                    ),
                  ],
                  SizedBox(height: mainSmallSpacing),
                  // 가입일
                  if (user.createdAt != null && user.createdAt!.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: p.textSecondary),
                        SizedBox(width: 4),
                        Text(
                          '가입일: ${_formatDate(user.createdAt!)}',
                          style: mainSmallTextStyle.copyWith(color: p.textSecondary),
                        ),
                      ],
                    ),
                    SizedBox(height: mainSmallSpacing),
                  ],
                  // 최근 접속일
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: p.textSecondary),
                      SizedBox(width: 4),
                      Text(
                        lastLoginAt != null && lastLoginAt.isNotEmpty
                            ? '최근 접속: ${_formatDate(lastLoginAt)}'
                            : '최근 접속: 없음',
                        style: mainSmallTextStyle.copyWith(color: p.textSecondary),
                      ),
                    ],
                  ),
                  SizedBox(height: mainSmallSpacing),
                  // 로그인 방식 표시
                  Wrap(
                    spacing: mainSmallSpacing,
                    runSpacing: mainSmallSpacing,
                    children: authProviders.map((authInfo) {
                      return Chip(
                        label: Text(
                          authInfo.displayName,
                          style: mainSmallTextStyle.copyWith(
                            color: authInfo.provider == 'local' ? p.textOnPrimary : p.textPrimary,
                          ),
                        ),
                        backgroundColor: authInfo.provider == 'local' 
                            ? p.primary 
                            : p.chipUnselectedBg,
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 사용자 상태 계산
  UserStatus _getUserStatus(User user, String? lastLoginAt) {
    // 탈퇴 회원 체크
    if (user.uQuitDate != null && user.uQuitDate!.isNotEmpty) {
      return UserStatus.quit;
    }
    
    // 휴면 회원 체크
    if (lastLoginAt != null && lastLoginAt.isNotEmpty) {
      try {
        final lastLoginDateTime = DateTime.parse(lastLoginAt);
        final now = DateTime.now();
        final daysDifference = now.difference(lastLoginDateTime).inDays;
        
        if (daysDifference >= config.dormantAccountDays) {
          return UserStatus.dormant;
        }
      } catch (e) {
        // 파싱 에러 무시
      }
    }
    
    return UserStatus.normal;
  }

  /// 사용자 상태 배지 빌드
  Widget _buildUserStatusBadge(UserStatus status, AppColorScheme p) {
    String label;
    Color backgroundColor;
    Color textColor;
    
    switch (status) {
      case UserStatus.normal:
        label = '일반 회원';
        backgroundColor = p.stockAvailable;
        textColor = p.textOnPrimary;
        break;
      case UserStatus.dormant:
        label = '휴면 회원';
        backgroundColor = p.stockLow;
        textColor = p.textOnPrimary;
        break;
      case UserStatus.quit:
        label = '탈퇴 회원';
        backgroundColor = p.stockOut;
        textColor = p.textOnPrimary;
        break;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: mainSmallBorderRadius,
      ),
      child: Text(
        label,
        style: mainSmallTextStyle.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 날짜 포맷팅
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final year = date.year.toString();
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      return '$year-$month-$day';
    } catch (e) {
      return dateString;
    }
  }

  /// 프로필 이미지 빌드
  Widget _buildProfileImage(int? userSeq, AppColorScheme p) {
    // 기본 이미지 위젯
    Widget defaultImageWidget = ClipOval(
      child: Image.asset(
        config.defaultProfileImage,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            color: p.divider,
            child: Icon(Icons.person, color: p.textSecondary),
          );
        },
      ),
    );

    if (userSeq == null) {
      return defaultImageWidget;
    }

    return FutureBuilder<Uint8List?>(
      future: _loadProfileImage(userSeq),
      builder: (context, snapshot) {
        // 이미지 로드 성공 시
        if (snapshot.hasData && snapshot.data != null) {
          try {
            return ClipOval(
              child: Image.memory(
                snapshot.data!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // 메모리 이미지 로드 실패 시 기본 이미지로 대체
                  return ClipOval(
                    child: Image.asset(
                      config.defaultProfileImage,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: p.divider,
                          child: Icon(Icons.person, color: p.textSecondary),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          } catch (e) {
            // 이미지 디코딩 실패 시 기본 이미지 표시
            return defaultImageWidget;
          }
        }
        
        // 이미지가 없거나 로드 중일 때 기본 이미지 표시
        return defaultImageWidget;
      },
    );
  }

  /// 프로필 이미지 로드
  Future<Uint8List?> _loadProfileImage(int userSeq) async {
    try {
      final baseUrl = config.getApiBaseUrl();
      final uri = Uri.parse('$baseUrl/api/users/$userSeq/profile_image');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      // 에러 무시
    }
    return null;
  }
}

/// 사용자와 인증 정보를 함께 저장하는 클래스
class UserWithAuth {
  final User user;
  final List<AuthProviderInfo> authProviders;
  final String? lastLoginAt;

  UserWithAuth({
    required this.user,
    required this.authProviders,
    this.lastLoginAt,
  });
}

/// 인증 제공자 정보
class AuthProviderInfo {
  final String provider;
  final String displayName;

  AuthProviderInfo({
    required this.provider,
    required this.displayName,
  });
}

/// 사용자 상태
enum UserStatus {
  normal,   // 일반 회원
  dormant,  // 휴면 회원
  quit,     // 탈퇴 회원
}

