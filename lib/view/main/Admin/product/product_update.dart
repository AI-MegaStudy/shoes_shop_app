import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/utils/custom_common_util.dart';
import 'package:shoes_shop_app/custom/external_util/network/custom_network_util.dart';
import 'package:shoes_shop_app/model/product_join.dart';
import 'package:shoes_shop_app/view/main/main_ui_config.dart';
import 'package:shoes_shop_app/theme/app_colors.dart';

/// 제품 수정 화면
class ProductUpdate extends StatefulWidget {
  final ProductJoin product;

  const ProductUpdate({
    super.key,
    required this.product,
  });

  @override
  State<ProductUpdate> createState() => _ProductUpdateState();
}

class _ProductUpdateState extends State<ProductUpdate> {
  final _formKey = GlobalKey<FormState>();

  // 카테고리 및 제조사 목록
  List<Map<String, dynamic>> _kindCategories = [];
  List<Map<String, dynamic>> _colorCategories = [];
  List<Map<String, dynamic>> _sizeCategories = [];
  List<Map<String, dynamic>> _genderCategories = [];
  List<Map<String, dynamic>> _makers = [];

  // 선택된 값
  int? _selectedKcSeq;
  int? _selectedCcSeq;
  int? _selectedScSeq;
  int? _selectedGcSeq;
  int? _selectedMSeq;

  // 입력 필드
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// 폼 초기화 (기존 제품 정보로 채우기)
  void _initializeForm() {
    // 제품 정보로 폼 채우기
    // 주의: ProductJoin에는 kc_seq, cc_seq 등이 없을 수 있으므로
    // API에서 전체 제품 정보를 다시 가져와야 할 수도 있음
    _nameController.text = widget.product.p_name ?? '';
    _priceController.text = widget.product.p_price?.toString() ?? '0';
    _stockController.text = widget.product.p_stock?.toString() ?? '0';
    // p_description은 ProductJoin에 없으므로 API에서 가져와야 함
  }

  /// 카테고리 및 제조사 목록 로드
  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      final apiBaseUrl = config.getApiBaseUrl();
      CustomNetworkUtil.setBaseUrl(apiBaseUrl);

      // 제품 상세 정보 로드 (카테고리 seq 포함)
      final productResponse = await CustomNetworkUtil.get<Map<String, dynamic>>(
        '/api/products/${widget.product.p_seq}',
        fromJson: (json) => json,
      );

      // 모든 카테고리 및 제조사 동시 로드
      final results = await Future.wait([
        CustomNetworkUtil.get<Map<String, dynamic>>(
          '/api/kind_categories',
          fromJson: (json) => json,
        ),
        CustomNetworkUtil.get<Map<String, dynamic>>(
          '/api/color_categories',
          fromJson: (json) => json,
        ),
        CustomNetworkUtil.get<Map<String, dynamic>>(
          '/api/size_categories',
          fromJson: (json) => json,
        ),
        CustomNetworkUtil.get<Map<String, dynamic>>(
          '/api/gender_categories',
          fromJson: (json) => json,
        ),
        CustomNetworkUtil.get<Map<String, dynamic>>(
          '/api/makers',
          fromJson: (json) => json,
        ),
      ]);

      setState(() {
        // 카테고리 목록 로드
        if (results[0].success && results[0].data != null) {
          _kindCategories = (results[0].data!['results'] as List<dynamic>?)
                  ?.map((e) => {'kc_seq': e['kc_seq'], 'kc_name': e['kc_name']})
                  .toList() ??
              [];
        }
        if (results[1].success && results[1].data != null) {
          _colorCategories = (results[1].data!['results'] as List<dynamic>?)
                  ?.map((e) => {'cc_seq': e['cc_seq'], 'cc_name': e['cc_name']})
                  .toList() ??
              [];
        }
        if (results[2].success && results[2].data != null) {
          _sizeCategories = (results[2].data!['results'] as List<dynamic>?)
                  ?.map((e) => {'sc_seq': e['sc_seq'], 'sc_name': e['sc_name']})
                  .toList() ??
              [];
        }
        if (results[3].success && results[3].data != null) {
          _genderCategories = (results[3].data!['results'] as List<dynamic>?)
                  ?.map((e) => {'gc_seq': e['gc_seq'], 'gc_name': e['gc_name']})
                  .toList() ??
              [];
        }
        if (results[4].success && results[4].data != null) {
          _makers = (results[4].data!['results'] as List<dynamic>?)
                  ?.map((e) => {'m_seq': e['m_seq'], 'm_name': e['m_name']})
                  .toList() ??
              [];
        }

        // 제품 정보로 선택된 값 설정 (카테고리 목록 로드 후에 설정)
        if (productResponse.success && productResponse.data != null) {
          final productData = productResponse.data!['result'] as Map<String, dynamic>?;
          if (productData != null) {
            // 드롭다운 선택 값 설정 (int로 변환하여 설정)
            final kcSeq = productData['kc_seq'];
            final ccSeq = productData['cc_seq'];
            final scSeq = productData['sc_seq'];
            final gcSeq = productData['gc_seq'];
            final mSeq = productData['m_seq'];
            
            _selectedKcSeq = kcSeq is int ? kcSeq : (kcSeq != null ? int.tryParse(kcSeq.toString()) : null);
            _selectedCcSeq = ccSeq is int ? ccSeq : (ccSeq != null ? int.tryParse(ccSeq.toString()) : null);
            _selectedScSeq = scSeq is int ? scSeq : (scSeq != null ? int.tryParse(scSeq.toString()) : null);
            _selectedGcSeq = gcSeq is int ? gcSeq : (gcSeq != null ? int.tryParse(gcSeq.toString()) : null);
            _selectedMSeq = mSeq is int ? mSeq : (mSeq != null ? int.tryParse(mSeq.toString()) : null);
            
            // 텍스트 필드 값 설정
            _nameController.text = productData['p_name']?.toString() ?? '';
            final price = productData['p_price'];
            _priceController.text = price != null ? price.toString() : '0';
            final stock = productData['p_stock'];
            _stockController.text = stock != null ? stock.toString() : '0';
            _descriptionController.text = productData['p_description']?.toString() ?? '';
          }
        }

        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      if (mounted) {
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          title: '오류',
          message: '카테고리 정보를 불러오는데 실패했습니다.',
        );
      }
    }
  }

  /// 제품 수정
  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.product.p_seq == null) {
      CustomCommonUtil.showErrorSnackbar(
        context: context,
        title: '오류',
        message: '제품 번호를 찾을 수 없습니다.',
      );
      return;
    }

    // 필수 필드 검증
    if (_selectedKcSeq == null ||
        _selectedCcSeq == null ||
        _selectedScSeq == null ||
        _selectedGcSeq == null ||
        _selectedMSeq == null) {
      CustomCommonUtil.showErrorSnackbar(
        context: context,
        title: '오류',
        message: '모든 카테고리와 제조사를 선택해주세요.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiBaseUrl = config.getApiBaseUrl();
      CustomNetworkUtil.setBaseUrl(apiBaseUrl);

      final response = await CustomNetworkUtil.post<Map<String, dynamic>>(
        '/api/products/${widget.product.p_seq}',
        body: {
          'kc_seq': _selectedKcSeq,
          'cc_seq': _selectedCcSeq,
          'sc_seq': _selectedScSeq,
          'gc_seq': _selectedGcSeq,
          'm_seq': _selectedMSeq,
          'p_name': _nameController.text.trim().isEmpty
              ? null
              : _nameController.text.trim(),
          'p_price': int.tryParse(_priceController.text.trim()) ?? 0,
          'p_stock': int.tryParse(_stockController.text.trim()) ?? 0,
          'p_description': _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        },
        fromJson: (json) => json,
      );

      setState(() {
        _isLoading = false;
      });

      if (response.success && response.data != null) {
        if (response.data!['result'] == 'OK') {
          CustomCommonUtil.showSuccessSnackbar(
            context: context,
            title: '성공',
            message: '제품이 수정되었습니다.',
          );
          Get.back(); // 목록 화면으로 돌아가기
        } else {
          CustomCommonUtil.showErrorSnackbar(
            context: context,
            title: '오류',
            message: response.data!['errorMsg'] ?? '제품 수정에 실패했습니다.',
          );
        }
      } else {
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          title: '오류',
          message: response.error ?? '제품 수정에 실패했습니다.',
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      CustomCommonUtil.showErrorSnackbar(
        context: context,
        title: '오류',
        message: '제품 수정 중 오류가 발생했습니다: $e',
      );
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
            title: const Text('제품 수정'),
            centerTitle: mainAppBarCenterTitle,
            titleTextStyle: mainAppBarTitleStyle.copyWith(color: p.textPrimary),
            backgroundColor: p.background,
            foregroundColor: p.textPrimary,
          ),
          body: SafeArea(
            child: _isLoadingCategories
                ? Center(child: CircularProgressIndicator(color: p.primary))
                : SingleChildScrollView(
                    padding: mainDefaultPadding,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                    // 종류 카테고리
                    Builder(
                      builder: (context) {
                        final p = context.palette;
                        return DropdownButtonFormField<int>(
                          value: _selectedKcSeq,
                          decoration: InputDecoration(
                            labelText: '종류 *',
                            border: const OutlineInputBorder(),
                            labelStyle: TextStyle(color: p.textSecondary),
                          ),
                          dropdownColor: p.cardBackground,
                          style: TextStyle(color: p.textPrimary),
                      items: _kindCategories.map((category) {
                        return DropdownMenuItem<int>(
                          value: category['kc_seq'] as int,
                          child: Text(category['kc_name'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedKcSeq = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) return '종류를 선택해주세요.';
                        return null;
                      },
                        );
                      },
                    ),
                    SizedBox(height: mainDefaultSpacing),

                    // 색상 카테고리
                    Builder(
                      builder: (context) {
                        final p = context.palette;
                        return DropdownButtonFormField<int>(
                          value: _selectedCcSeq,
                          decoration: InputDecoration(
                            labelText: '색상 *',
                            border: const OutlineInputBorder(),
                            labelStyle: TextStyle(color: p.textSecondary),
                          ),
                          dropdownColor: p.cardBackground,
                          style: TextStyle(color: p.textPrimary),
                      items: _colorCategories.map((category) {
                        return DropdownMenuItem<int>(
                          value: category['cc_seq'] as int,
                          child: Text(category['cc_name'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCcSeq = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) return '색상을 선택해주세요.';
                        return null;
                      },
                        );
                      },
                    ),
                    SizedBox(height: mainDefaultSpacing),

                    // 사이즈 카테고리
                    Builder(
                      builder: (context) {
                        final p = context.palette;
                        return DropdownButtonFormField<int>(
                          value: _selectedScSeq,
                          decoration: InputDecoration(
                            labelText: '사이즈 *',
                            border: const OutlineInputBorder(),
                            labelStyle: TextStyle(color: p.textSecondary),
                          ),
                          dropdownColor: p.cardBackground,
                          style: TextStyle(color: p.textPrimary),
                      items: _sizeCategories.map((category) {
                        return DropdownMenuItem<int>(
                          value: category['sc_seq'] as int,
                          child: Text(category['sc_name'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedScSeq = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) return '사이즈를 선택해주세요.';
                        return null;
                      },
                        );
                      },
                    ),
                    SizedBox(height: mainDefaultSpacing),

                    // 성별 카테고리
                    Builder(
                      builder: (context) {
                        final p = context.palette;
                        return DropdownButtonFormField<int>(
                          value: _selectedGcSeq,
                          decoration: InputDecoration(
                            labelText: '성별 *',
                            border: const OutlineInputBorder(),
                            labelStyle: TextStyle(color: p.textSecondary),
                          ),
                          dropdownColor: p.cardBackground,
                          style: TextStyle(color: p.textPrimary),
                      items: _genderCategories.map((category) {
                        return DropdownMenuItem<int>(
                          value: category['gc_seq'] as int,
                          child: Text(category['gc_name'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGcSeq = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) return '성별을 선택해주세요.';
                        return null;
                      },
                        );
                      },
                    ),
                    SizedBox(height: mainDefaultSpacing),

                    // 제조사
                    Builder(
                      builder: (context) {
                        final p = context.palette;
                        return DropdownButtonFormField<int>(
                          value: _selectedMSeq,
                          decoration: InputDecoration(
                            labelText: '제조사 *',
                            border: const OutlineInputBorder(),
                            labelStyle: TextStyle(color: p.textSecondary),
                          ),
                          dropdownColor: p.cardBackground,
                          style: TextStyle(color: p.textPrimary),
                      items: _makers.map((maker) {
                        return DropdownMenuItem<int>(
                          value: maker['m_seq'] as int,
                          child: Text(maker['m_name'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMSeq = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) return '제조사를 선택해주세요.';
                        return null;
                      },
                        );
                      },
                    ),
                    SizedBox(height: mainDefaultSpacing),

                    // 제품명
                    Builder(
                      builder: (context) {
                        final p = context.palette;
                        return TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: '제품명',
                            border: const OutlineInputBorder(),
                            labelStyle: TextStyle(color: p.textSecondary),
                          ),
                          style: TextStyle(color: p.textPrimary),
                        );
                      },
                    ),
                    SizedBox(height: mainDefaultSpacing),

                    // 가격
                    Builder(
                      builder: (context) {
                        final p = context.palette;
                        return TextFormField(
                          controller: _priceController,
                          decoration: InputDecoration(
                            labelText: '가격',
                            border: const OutlineInputBorder(),
                            labelStyle: TextStyle(color: p.textSecondary),
                          ),
                          style: TextStyle(color: p.textPrimary),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final price = int.tryParse(value);
                              if (price == null || price < 0) {
                                return '올바른 가격을 입력해주세요.';
                              }
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    SizedBox(height: mainDefaultSpacing),

                    // 재고
                    Builder(
                      builder: (context) {
                        final p = context.palette;
                        return TextFormField(
                          controller: _stockController,
                          decoration: InputDecoration(
                            labelText: '재고',
                            border: const OutlineInputBorder(),
                            labelStyle: TextStyle(color: p.textSecondary),
                          ),
                          style: TextStyle(color: p.textPrimary),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final stock = int.tryParse(value);
                              if (stock == null || stock < 0) {
                                return '올바른 재고 수량을 입력해주세요.';
                              }
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    SizedBox(height: mainDefaultSpacing),

                    // 설명
                    Builder(
                      builder: (context) {
                        final p = context.palette;
                        return TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: '제품 설명',
                            border: const OutlineInputBorder(),
                            labelStyle: TextStyle(color: p.textSecondary),
                          ),
                          style: TextStyle(color: p.textPrimary),
                          maxLines: 3,
                        );
                      },
                    ),
                    SizedBox(height: mainLargeSpacing),

                    // 수정 버튼
                    Center(
                      child: SizedBox(
                        width: mainButtonMaxWidth,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateProduct,
                          style: mainPrimaryButtonStyle.copyWith(
                            backgroundColor: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.disabled)) {
                                return p.divider;
                              }
                              return p.primary;
                            }),
                            foregroundColor: WidgetStateProperty.all(p.textOnPrimary),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: p.textOnPrimary,
                                  ),
                                )
                              : const Text(
                                  '제품 수정',
                                  style: mainMediumTitleStyle,
                                ),
                        ),
                      ),
                    ),
                      ],
                    ),
                  ),
                ),
          ),
        );
      },
    );
  }
}

