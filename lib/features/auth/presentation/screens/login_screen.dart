import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_text_field.dart';
import 'HomeScreen.dart';
import 'forgot_password_screen.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'من فضلك ادخل البريد الإلكتروني وكلمة المرور',
          ),
        ),
      );
      return;
    }

    context.read<AuthCubit>().login(
      email,
      password,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const Homescreen(),
              ),
            );
          }

          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        const Text(
                          '🐾',
                          style: TextStyle(fontSize: 26),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'مرحبا بعودتك',
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Center(
                      child: Text(
                        'سجل دخولك للمتابعة',
                        style:
                        AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 42),

                    Text(
                      'البريد الإلكتروني',
                      style:
                      AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    AuthTextField(
                      controller: _emailController,
                      hintText: 'ادخل بريدك الإلكتروني',
                      icon: Icons.mail_outline_rounded,
                      keyboardType:
                      TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 22),

                    Text(
                      'كلمة المرور',
                      style:
                      AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    AuthTextField(
                      controller: _passwordController,
                      hintText:
                      'ادخل كلمة المرور الخاصة بك',
                      icon: _obscurePassword
                          ? Icons.lock_outline_rounded
                          : Icons.lock_open_rounded,
                      obscureText: _obscurePassword,
                      onIconPressed: () {
                        setState(() {
                          _obscurePassword =
                          !_obscurePassword;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'نسيت كلمة المرور؟',
                          style:
                          AppTextStyles.body.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final isLoading =
                        state is AuthLoading;

                        return SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed:
                            isLoading ? null : _login,
                            child: isLoading
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                              CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text(
                              'سجل دخول',
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 60),

                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const SignUpScreen(),
                            ),
                          );
                        },
                        child: Text.rich(
                          TextSpan(
                            text: 'ليس لديك حساب؟ ',
                            style: AppTextStyles.body,
                            children: [
                              TextSpan(
                                text: 'أنشئ حساب',
                                style:
                                AppTextStyles.body.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}