import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController =
  TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetEmail() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'من فضلك ادخل البريد الإلكتروني',
          ),
        ),
      );
      return;
    }

    context.read<AuthCubit>().sendPasswordResetEmail(
      email,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is PasswordResetEmailSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
                ),
              ),
            );

            Navigator.pop(context);
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
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.mainText,
                        size: 22,
                      ),
                      onPressed: () {
                        Navigator.maybePop(context);
                      },
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),

                        Center(
                          child: Text(
                            'نسيت كلمة المرور؟',
                            style:
                            AppTextStyles.h1.copyWith(
                              color: AppColors.mainText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Center(
                          child: Text(
                            'من فضلك ادخل بريدك الإلكتروني\nلنقوم بإرسال رابط إعادة تعيين كلمة المرور',
                            style: AppTextStyles.bodyLarge
                                .copyWith(
                              color:
                              AppColors.secondaryText,
                              fontWeight:
                              FontWeight.w500,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 48),

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
                          hintText:
                          'ادخل بريدك الإلكتروني',
                          icon:
                          Icons.mail_outline_rounded,
                          keyboardType:
                          TextInputType.emailAddress,
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
                                    : _sendResetEmail,
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
                                  'أرسل',
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 32),
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