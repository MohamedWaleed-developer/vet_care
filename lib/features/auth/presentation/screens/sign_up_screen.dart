import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_text_field.dart';
import 'HomeScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController =
  TextEditingController();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword =
    _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'من فضلك املأ جميع البيانات',
          ),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'كلمتا المرور غير متطابقتين',
          ),
        ),
      );
      return;
    }

    context.read<AuthCubit>().signUp(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const Homescreen(),
              ),
                  (route) => false,
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.mainText,
                          size: 22,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'إنشاء حساب',
                            style: AppTextStyles.h2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),

                        Text(
                          'الاسم',
                          style:
                          AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        AuthTextField(
                          controller: _nameController,
                          hintText: 'ادخل اسمك',
                          icon:
                          Icons.person_outline_rounded,
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'البريد الإلكتروني',
                          style:
                          AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        AuthTextField(
                          controller: _emailController,
                          hintText:
                          'ادخل بريدك الإلكتروني',
                          icon:
                          Icons.mail_outline_rounded,
                          keyboardType:
                          TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'كلمة المرور',
                          style:
                          AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        AuthTextField(
                          controller: _passwordController,
                          hintText:
                          'ادخل كلمة المرور الخاصة بك',
                          icon: _obscurePassword
                              ? Icons.lock_outline_rounded
                              : Icons.lock_open_rounded,
                          obscureText:
                          _obscurePassword,
                          onIconPressed: () {
                            setState(() {
                              _obscurePassword =
                              !_obscurePassword;
                            });
                          },
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'تأكيد كلمة المرور',
                          style:
                          AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        AuthTextField(
                          controller:
                          _confirmPasswordController,
                          hintText:
                          'أعد إدخال كلمة المرور',
                          icon: _obscureConfirmPassword
                              ? Icons.lock_outline_rounded
                              : Icons.lock_open_rounded,
                          obscureText:
                          _obscureConfirmPassword,
                          onIconPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                              !_obscureConfirmPassword;
                            });
                          },
                        ),

                        const SizedBox(height: 36),

                        BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            final isLoading =
                            state is AuthLoading;

                            return SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : _signUp,
                                child: isLoading
                                    ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child:
                                  CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:
                                    Colors.white,
                                  ),
                                )
                                    : const Text(
                                  'إنشاء حساب',
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 32),

                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Text.rich(
                              TextSpan(
                                text:
                                'لدي حساب بالفعل؟ ',
                                style:
                                AppTextStyles.body,
                                children: [
                                  TextSpan(
                                    text: 'سجل دخول',
                                    style: AppTextStyles.body
                                        .copyWith(
                                      color:
                                      AppColors.primary,
                                      fontWeight:
                                      FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}