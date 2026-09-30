import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../data/models/vaccination_model.dart';
import '../cubit/vaccinations_cubit.dart';
import '../cubit/vaccinations_state.dart';

class VaccinationsView extends StatefulWidget {
  final String petId;

  const VaccinationsView({
    super.key,
    required this.petId,
  });

  @override
  State<VaccinationsView> createState() => _VaccinationsViewState();
}

class _VaccinationsViewState extends State<VaccinationsView> {
  @override
  void initState() {
    super.initState();

    // أول ما الشاشة تفتح، نجيب تطعيمات الحيوان
    context.read<VaccinationsCubit>().getVaccinations(widget.petId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF173F3F),
        centerTitle: true,
        title: const Text(
          'تطعيمات الحيوان',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocBuilder<VaccinationsCubit, VaccinationsState>(
        builder: (context, state) {
          // حالة التحميل
          if (state is VaccinationsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // حالة الخطأ
          if (state is VaccinationsError) {
            return _buildErrorState(
              context,
              state.message,
            );
          }

          // حالة النجاح
          if (state is VaccinationsLoaded) {
            return _buildVaccinationsList(
              context,
              state.vaccinations,
            );
          }

          // الحالة الابتدائية
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ===========================================================
  // قائمة التطعيمات
  // ===========================================================

  Widget _buildVaccinationsList(
      BuildContext context,
      List<VaccinationModel> vaccinations,
      ) {
    if (vaccinations.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () {
        return context
            .read<VaccinationsCubit>()
            .getVaccinations(widget.petId);
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: vaccinations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final vaccination = vaccinations[index];

          return _buildVaccinationCard(
            vaccination,
          );
        },
      ),
    );
  }

  // ===========================================================
  // Card التطعيم
  // ===========================================================

  Widget _buildVaccinationCard(
      VaccinationModel vaccination,
      ) {
    final bool isToday = _isToday(vaccination.dueDate);

    final bool isOverdue = vaccination.dueDate.isBefore(
      DateTime.now(),
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5ECEC),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة التطعيم
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F4F2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.vaccines_outlined,
              color: Color(0xFF178B82),
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          // بيانات التطعيم
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccination.vaccineName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF173F3F),
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 15,
                      color: Color(0xFF718181),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('dd/MM/yyyy').format(
                        vaccination.dueDate,
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF718181),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // حالة التطعيم
          _buildStatusBadge(
            isToday: isToday,
            isOverdue: isOverdue,
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // Badge الحالة
  // ===========================================================

  Widget _buildStatusBadge({
    required bool isToday,
    required bool isOverdue,
  }) {
    String text;
    Color backgroundColor;
    Color textColor;

    if (isToday) {
      text = 'اليوم';
      backgroundColor = const Color(0xFFFFF4D8);
      textColor = const Color(0xFF9A7410);
    } else if (isOverdue) {
      text = 'متأخر';
      backgroundColor = const Color(0xFFFFE7E7);
      textColor = const Color(0xFFC84A4A);
    } else {
      text = 'قادم';
      backgroundColor = const Color(0xFFE6F4F2);
      textColor = const Color(0xFF178B82);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  // ===========================================================
  // Empty State
  // ===========================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F4F2),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.vaccines_outlined,
                size: 45,
                color: Color(0xFF178B82),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'لا توجد تطعيمات حالياً',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF173F3F),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'ستظهر مواعيد التطعيمات الخاصة بالحيوان هنا.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF718181),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // Error State
  // ===========================================================

  Widget _buildErrorState(
      BuildContext context,
      String message,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 55,
              color: Color(0xFFC84A4A),
            ),

            const SizedBox(height: 16),

            const Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF173F3F),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF718181),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                context
                    .read<VaccinationsCubit>()
                    .getVaccinations(widget.petId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF178B82),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'إعادة المحاولة',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // هل الموعد هو اليوم؟
  // ===========================================================

  bool _isToday(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}