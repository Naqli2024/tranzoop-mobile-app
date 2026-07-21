import 'package:cherry_toast/cherry_toast.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:tranzoop_mobile_app/core/utils/shared_preferences.dart';
import 'package:tranzoop_mobile_app/core/utils/view_utils.dart';
import 'package:tranzoop_mobile_app/core/app_colors.dart';
import 'package:tranzoop_mobile_app/features/auth/view/login_screen.dart';

class BasicWidgets {

  AppBar buildCommonEmptyAppBar(Color bgColor) {
    return AppBar(
      toolbarHeight: 4,
      backgroundColor: bgColor,
      automaticallyImplyLeading: false,
    );
  }

  AppBar buildCommonAppBar({
    required BuildContext context,
    required String title,
    bool centerTitle = true,
    bool showBackButton = true,
    VoidCallback? onBackPressed,
  }) {
    ViewUtil viewUtil = ViewUtil(context);
    return AppBar(
      toolbarHeight: viewUtil.isTablet ? 100 : 70,
      elevation: 0,
      centerTitle: centerTitle,
      backgroundColor: AppColors.btnColor,
      foregroundColor: Colors.white,
      leading: showBackButton
          ? GestureDetector(
        onTap: onBackPressed ??
                () {
              Navigator.pop(context);
            },
        child: Icon(Icons.arrow_back_outlined,size: viewUtil.isTablet ?30 :25),
      )
          : null,

      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: viewUtil.isTablet ?30 :20,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  AppBar buildAppBarWithRadius({
    required BuildContext context,
    required String title,
    bool centerTitle = true,
    bool showBackButton = true,
    VoidCallback? onBackPressed,
  }) {
    ViewUtil viewUtil = ViewUtil(context);
    return AppBar(
      toolbarHeight: viewUtil.isTablet ? 100 : 70,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      elevation: 0,
      centerTitle: centerTitle,
      backgroundColor: AppColors.btnColor,
      foregroundColor: Colors.white,
      leading: showBackButton
          ? GestureDetector(
        onTap: onBackPressed ??
                () {
              Navigator.pop(context);
            },
        child: Icon(Icons.arrow_back_outlined,size: viewUtil.isTablet ?30 :25),
      )
          : Container(),

      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: viewUtil.isTablet ?30 :20,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  void showLogoutDialog(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    SharedPrefService _pref = SharedPrefService();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: viewUtil.isTablet?0 :25),
          contentPadding: EdgeInsets.symmetric(
            horizontal: viewUtil.isTablet?90 :20,
            vertical: viewUtil.isTablet?40 :15,
          ),
          title: CircleAvatar(
              maxRadius: viewUtil.isTablet ?60 :40,
              child: Icon(Icons.directions_run,size: viewUtil.isTablet ?60 :40,)),
          content: Text("Are you sure you want to logout?",textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: viewUtil.isTablet?22 :15,
                fontWeight: FontWeight.w500,
              )),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      _pref.clearUserData();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: viewUtil.isTablet?12 :8),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text("Logout",textAlign: TextAlign.center, style: TextStyle(color: Colors.red,fontSize: viewUtil.isTablet?18 :15)),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(AppColors.btnColor),
                      padding: WidgetStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 20, vertical: viewUtil.isTablet?12 :8),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text("No, Continue",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: viewUtil.isTablet?18 :15,
                        )),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  TextStyle coloredText(BuildContext context,color,double fontSize,fontWeight) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  Widget buildTextField(
      String label,
      TextEditingController controller, {
        int? maxLines = 1,
        FocusNode? focusNode,
        String? hintText,
        String? labelText,
        bool obscureText = false,
        bool readOnly = false,
        bool isDateField = false,
        bool isNumber = false,
        FontWeight fontWeight = FontWeight.w500,
        Widget? suffixIcon,
        TextEditingController? passwordController,
        required BuildContext context,
      }) {
    ViewUtil viewUtil = ViewUtil(context);

    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(
            vertical: 10,
          ),
          alignment: Alignment.topLeft,
          child: Text(label, overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: viewUtil.isTablet ? 20 : 14,
                fontWeight: FontWeight.normal,
                color: AppColors.blackColor,
              )),
        ),
        TextFormField(
          style: TextStyle(fontSize: viewUtil.isTablet ? 18 : 14),
          readOnly: isDateField ? true : readOnly,
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumber
              ? [FilteringTextInputFormatter.digitsOnly]
              : [],
          onTap: isDateField
              ? () async {
            FocusScope.of(context).requestFocus(FocusNode());

            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );

            if (pickedDate != null) {
              controller.text = pickedDate.toString().split(' ')[0];
            }
          }
              : null,
          decoration: InputDecoration(
            hintText: hintText ?? '',
            labelText: labelText ?? '',
            contentPadding: EdgeInsets.symmetric(
              horizontal: 3,
              vertical: viewUtil.isTablet ? 20 : 0,
            ),
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.borderColor),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            suffixIcon: isDateField
                ? const Icon(Icons.calendar_today, size: 15)
                : suffixIcon,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '${'Please enter'} $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget buildCommonDropdown<T>({
    required BuildContext context,
    required String label,
    required List<T> items,
    required T? value,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
    String hint = 'Select',
    bool isRequired = true,
  }) {
    ViewUtil viewUtil = ViewUtil(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Text(label, style: TextStyle(
            fontSize: viewUtil.isTablet ? 20 : 14,
            fontWeight: FontWeight.normal,
            color: AppColors.blackColor,
          )),
        ),

        DropdownButtonFormField2<T>(
          value: value,
          isExpanded: true,
          buttonStyleData: const ButtonStyleData(width: 150),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          hint: Text(
            hint,
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.normal,
              fontSize: viewUtil.isTablet ?18 :14,
            ),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel(item),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: viewUtil.isTablet ?18 :14,
                ),
              ),
            ),
          )
              .toList(),
          onChanged: onChanged,
          validator: isRequired
              ? (val) => val == null ? '${'Please select'} $label' : null
              : null,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
          ),
          iconStyleData: const IconStyleData(
            icon: Icon(Icons.keyboard_arrow_down),
          ),
        ),
      ],
    );
  }

  Widget buildCommonButton(
      BuildContext context,
      String text,
      VoidCallback? onButtonPressed, {
        bool isLoading = false,
      }) {
    ViewUtil viewUtil = ViewUtil(context);
    BasicWidgets basicWidgets = BasicWidgets();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: viewUtil.isTablet ? 40 : 16,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.06,
        width: MediaQuery.of(context).size.width,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff2563EB),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: isLoading ? null : onButtonPressed,
          child: isLoading
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
              : Text(
            text,
            textAlign: TextAlign.center,
            style: basicWidgets.coloredText(
              context,
              Colors.white,
              viewUtil.isTablet ? 24 : 16,
              FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSlideActionButton({
    required BuildContext context,
    required Animation<double> animation,
    required String text,
    required VoidCallback onSubmit,
    bool isTablet = false,
    Color outerColor = Colors.blue,
    Color innerColor = const Color(0xff6889da),
  }) {
    ViewUtil viewUtil = ViewUtil(context);
    return Container(
      margin: EdgeInsets.fromLTRB(20,0,20,MediaQuery.of(context).padding.bottom + 12),
      child: SlideAction(
        height: viewUtil.isTablet ?80 :65,
        borderRadius: 12,
        elevation: 0,
        submittedIcon: Icon(
          Icons.check_circle_outlined,
          color: Colors.white,
          size: isTablet ? 30 : 26,
        ),
        innerColor: innerColor,
        outerColor: outerColor,
        sliderButtonIcon: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(animation.value, 0),
              child: Icon(
                Icons.arrow_forward_outlined,
                color: Colors.white,
                size: isTablet ? 30 : 20,
              ),
            );
          },
        ),
        text: text,
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: isTablet ? 24 : 16,
          fontWeight: FontWeight.w500,
        ),
        onSubmit: () async {
          onSubmit();
          return null;
        },
      ),
    );
  }

  void success(BuildContext context, String message) {
    CherryToast.success(
      title: Text(
        "Success",
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      action: Text(message, style: const TextStyle(color: Colors.black)),
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 200),
      borderRadius: 8,
    ).show(context);
  }

  void info(BuildContext context, String message) {
    CherryToast.info(
      title: Text(
        'Information',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      action: Text(message, style: const TextStyle(color: Colors.black)),
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 200),
      borderRadius: 8,
    ).show(context);
  }

  void error(BuildContext context, String message) {
    CherryToast.error(
      title: Text(
        'Error',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      action: Text(message, style: const TextStyle(color: Colors.black)),
      animationDuration: const Duration(milliseconds: 800),
      borderRadius: 8,
    ).show(context);
  }

  Widget loading() {
    return Center(
      child: LoadingAnimationWidget.fourRotatingDots(
        color: AppColors.btnColor,
        size: 60,
      ),
    );
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Center(
            child: LoadingAnimationWidget.fourRotatingDots(
              color: AppColors.btnColor,
              size: 60,
            ),
          ),
        );
      },
    );
  }
}