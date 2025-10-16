import 'package:flutter/material.dart';
import '../../utils/page_transitions.dart';
import '../../utils/responsive_helper.dart';
import 'profile_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入用户名';
    }
    if (value.length < 3) {
      return '用户名至少需要3个字符';
    }
    if (value.length > 20) {
      return '用户名不能超过20个字符';
    }
    // 检查是否包含特殊字符
    if (!RegExp(r'^[a-zA-Z0-9_\u4e00-\u9fa5]+$').hasMatch(value)) {
      return '用户名只能包含字母、数字、下划线和中文';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 6) {
      return '密码至少需要6个字符';
    }
    if (value.length > 20) {
      return '密码不能超过20个字符';
    }
    // 检查密码强度
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
      return '密码必须包含字母和数字';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 模拟登录API调用
      await Future.delayed(const Duration(seconds: 2));
      
      // 这里应该是实际的登录逻辑
      if (_usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
         // 登录成功，跳转到档案设置页面
         if (mounted) {
           Navigator.of(context).pushReplacementWithFadeSlideTransition(
             const ProfileSetupScreen(),
           );
         }
      } else {
        setState(() {
          _errorMessage = '用户名或密码错误';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '登录失败，请重试';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ResponsiveContainer(
              mobilePadding: const EdgeInsets.all(24.0),
              tabletPadding: const EdgeInsets.all(48.0),
              desktopPadding: const EdgeInsets.all(64.0),
              mobileMaxWidth: double.infinity,
              tabletMaxWidth: 600,
              desktopMaxWidth: 500,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: ResponsiveHelper.getResponsiveHeight(
                        context,
                        mobile: 60,
                        tablet: 80,
                        desktop: 100,
                      )),
                      
                      // Logo和标题
                      _buildHeader(),
                      
                      SizedBox(height: ResponsiveHelper.getResponsiveHeight(
                        context,
                        mobile: 60,
                        tablet: 80,
                        desktop: 100,
                      )),
                      
                      // 登录表单
                      _buildLoginForm(),
                      
                      SizedBox(height: ResponsiveHelper.getResponsiveHeight(
                        context,
                        mobile: 40,
                        tablet: 60,
                        desktop: 80,
                      )),
                      
                      // 其他登录选项
                      _buildAlternativeOptions(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo圆形容器
        Container(
          width: ResponsiveHelper.getResponsiveWidth(
            context,
            mobile: 120,
            tablet: 140,
            desktop: 160,
          ),
          height: ResponsiveHelper.getResponsiveHeight(
            context,
            mobile: 120,
            tablet: 140,
            desktop: 160,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFFB74D),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.pets,
            size: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 50,
              tablet: 60,
              desktop: 70,
            ),
            color: const Color(0xFF5D4037),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // 标题
        Text(
          'Felo',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 32,
              tablet: 36,
              desktop: 40,
            ),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C2C2C),
            letterSpacing: 1.2,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          '欢迎回来',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 18,
              tablet: 20,
              desktop: 22,
            ),
            color: const Color(0xFF666666),
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          '登录您的宠物智能管理账户',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 14,
              tablet: 16,
              desktop: 18,
            ),
            color: const Color(0xFF999999),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 错误提示
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
              )),
              margin: EdgeInsets.only(bottom: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobile: 20,
                tablet: 24,
                desktop: 28,
              )),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade600,
                    size: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 20,
                      tablet: 22,
                      desktop: 24,
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.getResponsiveSpacing(
                    context,
                    mobile: 12,
                    tablet: 14,
                    desktop: 16,
                  )),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // 用户名输入框
          _buildInputField(
            controller: _usernameController,
            label: '用户名',
            hint: '请输入用户名',
            icon: Icons.person_outline,
            validator: _validateUsername,
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(
            context,
            mobile: 20,
            tablet: 24,
            desktop: 28,
          )),
          
          // 密码输入框
          _buildInputField(
            controller: _passwordController,
            label: '密码',
            hint: '请输入密码',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF999999),
                size: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 20,
                  tablet: 22,
                  desktop: 24,
                ),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: _validatePassword,
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(
            context,
            mobile: 32,
            tablet: 40,
            desktop: 48,
          )),
          
          // 登录按钮
          SizedBox(
            width: double.infinity,
            height: ResponsiveHelper.getResponsiveHeight(
              context,
              mobile: 56,
              tablet: 64,
              desktop: 72,
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: const Color(0xFFFFCC80),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: ResponsiveHelper.getResponsiveWidth(
                        context,
                        mobile: 24,
                        tablet: 28,
                        desktop: 32,
                      ),
                      height: ResponsiveHelper.getResponsiveHeight(
                        context,
                        mobile: 24,
                        tablet: 28,
                        desktop: 32,
                      ),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      '登录',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFFBBBBBB),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF999999),
              size: 20,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFF9800),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red.shade400,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red.shade400,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlternativeOptions() {
    return Column(
      children: [
        // 忘记密码
        TextButton(
          onPressed: () {
            // TODO: 实现忘记密码功能
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('忘记密码功能开发中')),
            );
          },
          child: const Text(
            '忘记密码？',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 14,
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // 分割线
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: Colors.grey.shade300,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '或',
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: Colors.grey.shade300,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // 注册按钮
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              // TODO: 跳转到注册页面
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('注册功能开发中')),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF666666),
              side: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              '创建新账户',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 40),
        
        // 提示信息
        const Text(
          '测试账户：admin / 123456',
          style: TextStyle(
            color: Color(0xFFBBBBBB),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}