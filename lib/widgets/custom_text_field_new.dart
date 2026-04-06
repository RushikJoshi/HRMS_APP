import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/app_colors.dart';
import '../utils/responsive_utility.dart';
import '../utils/language_manager_utility.dart';
import 'compatibility_theming.dart';
import 'custom_text.dart';


class NewTextField extends StatefulWidget {
  // All your original properties are kept.
  final String? label;
  final String? prefixIconPath;
  final String? suffixIconPath;
  final int? maxLines;
  final bool isRequired;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final bool? enabled;
  final Function(String)? onChange;
  final Function()? onTap;
  final TextEditingController? controller;
  final GlobalKey<FormFieldState>? formFieldKey;
  final bool? isKey;
  final Widget? suffix;
  final Widget? prefix;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final TextInputAction? textInputAction;

  const NewTextField({
    super.key,
    this.label,
    this.prefixIconPath,
    this.suffixIconPath,
    this.maxLines,
    this.isRequired = false,
    this.hintText,
    this.validator,
    this.focusNode,
    this.keyboardType,
    this.enabled,
    this.onChange,
    this.onTap,
    this.controller,
    this.formFieldKey,
    this.isKey = true,
    this.suffix,
    this.prefix,
    this.minLines,
    this.inputFormatters,
    this.obscureText = false,
    this.textInputAction,
  });

  @override
  State<NewTextField> createState() => _NewTextFieldState();
}

class _NewTextFieldState extends State<NewTextField> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() {
    final formFieldState = widget.formFieldKey?.currentState;
    if (formFieldState != null &&
        formFieldState.value != widget.controller?.text) {
      formFieldState.didChange(widget.controller?.text);
      if (formFieldState.hasError) {
        formFieldState.validate();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.getResponsive(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null && widget.label!.isNotEmpty) ...[
          Row(
            children: [
              CustomText(
                widget.label!,
                color: AppTheme.getColor(context).onSurfaceVariant,
                fontSize: 14 * r,
                fontWeight: FontWeight.w700,
              ),
              if (widget.isRequired) ...[
                CustomText(
                  '*',
                  color: AppColors.red,
                  fontSize: 14 * r,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ],
          ),
          SizedBox(height: 0.004 * Responsive.getHeight(context)),
        ],
        FormField<String>(
          key: widget.formFieldKey,
          validator: widget.validator,
          builder: (FormFieldState<String> field) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (field.value != widget.controller?.text) {
                field.didChange(widget.controller?.text);
              }
            });
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: widget.onTap,
                  child: Container(
                    // height: 44 * Responsive.getResponsive(context),
                    padding: EdgeInsets.symmetric(horizontal: 10 * r),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12 * r),
                      color: AppTheme.getColor(context).surfaceBright,
                      border: Border.all(
                        color: field.hasError
                            ? AppColors.error
                            : AppTheme.getColor(context).outline,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (widget.prefix != null)
                          Center(child: widget.prefix)
                        else if (widget.prefixIconPath != null)
                          Padding(
                            padding: EdgeInsets.only(right: 0 * r),
                            child: SvgPicture.asset(
                              widget.prefixIconPath!,
                              height: 0.022 * Responsive.getHeight(context),
                            ),
                          ),
                        Expanded(
                          // ✅ FIX: Wrap TextFormField with IgnorePointer.
                          child: IgnorePointer(
                            ignoring: widget.onTap != null,
                            child: TextFormField(
                              readOnly: widget.onTap != null,
                              minLines: widget.minLines ?? 1,
                              maxLines: widget.maxLines ?? 1,
                              style: TextStyle(
                                fontSize: 16 * r,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.getColor(context).onSurface,
                              ),
                              enabled: widget.enabled,
                              focusNode: widget.focusNode,
                              obscureText: widget.obscureText,
                              textInputAction: widget.textInputAction,
                              keyboardType: widget.keyboardType,
                              controller: widget.controller,
                              inputFormatters: widget.inputFormatters,
                              decoration: InputDecoration(
                                hintText: LanguageManager().get(
                                  widget.hintText.toString(),
                                ),
                                suffixIcon: widget.suffixIconPath == null
                                    ? widget.suffix
                                    : Padding(
                                        padding: EdgeInsets.only(
                                          left: 8 * r,
                                          right: 12 * r,
                                        ),
                                        child: SvgPicture.asset(
                                          widget.suffixIconPath!,
                                          height:
                                              0.022 *
                                              Responsive.getHeight(context),
                                        ),
                                      ),
                                suffixIconConstraints:
                                    widget.suffixIconPath != null
                                    ? BoxConstraints(
                                        minHeight:
                                            0.022 *
                                            Responsive.getHeight(context),
                                        minWidth:
                                            (12 + 8) * r +
                                            0.022 *
                                                Responsive.getHeight(context),
                                      )
                                    : null,
                                filled: true,
                                hintStyle: TextStyle(
                                  fontSize: 14 * r,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.getColor(context).outline,
                                ),

                                fillColor: AppTheme.getColor(
                                  context,
                                ).surfaceBright,
                                contentPadding: EdgeInsets.only(
                                  top: 14 * r,
                                  left: 12 * r,
                                  bottom: 13 * r,
                                ),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                              ),
                              onChanged: (value) {
                                widget.onChange?.call(value);
                                field.didChange(value);
                                field.validate();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (field.hasError)
                  Padding(
                    padding: EdgeInsets.only(top: 4 * r, left: 10 * r),
                    child: CustomText(
                      field.errorText ?? 'Validation error',
                      color: AppColors.red,
                      fontSize: 12 * r,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
