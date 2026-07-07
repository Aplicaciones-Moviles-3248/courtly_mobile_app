import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/infrastructure/http/api_client.dart';
import '../../../../shared/infrastructure/storage/local_storage_service.dart';
import '../../../courts/application/use_cases/get_courts_use_case.dart';
import '../../../courts/domain/entities/court.dart';
import '../../../courts/infrastructure/datasources/court_remote_data_source.dart';
import '../../../courts/infrastructure/repositories/court_repository_impl.dart';
import '../../../users/application/use_cases/get_my_user_profile_use_case.dart';
import '../../../users/domain/entities/user_profile.dart';
import '../../../users/infrastructure/datasources/user_profile_remote_data_source.dart';
import '../../../users/infrastructure/repositories/user_profile_repository_impl.dart';
import '../../application/use_cases/create_match_use_case.dart';
import '../../infrastructure/datasources/match_remote_data_source.dart';
import '../../infrastructure/repositories/match_repository_impl.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final CreateMatchUseCase createMatchUseCase;
  late final GetCourtsUseCase getCourtsUseCase;
  late final GetMyUserProfileUseCase getMyUserProfileUseCase;

  // Form Fields
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _maxPlayers = 10;
  String? _selectedCourtId;

  List<Court> courts = [];
  UserProfile? currentUser;
  bool isLoading = true;
  String? errorMessage;

  // Contact list for invitation
  final List<Map<String, dynamic>> _contacts = [
    {'id': '101', 'name': 'Fabricio', 'selected': false},
    {'id': '102', 'name': 'Eduardo', 'selected': false},
    {'id': '103', 'name': 'Pedro', 'selected': false},
    {'id': '104', 'name': 'Camilla', 'selected': false},
  ];

  @override
  void initState() {
    super.initState();
    final localStorage = LocalStorageService();
    final apiClient = ApiClient(localStorage);

    // Matches
    final matchDataSource = MatchRemoteDataSource(apiClient);
    final matchRepository = MatchRepositoryImpl(matchDataSource);
    createMatchUseCase = CreateMatchUseCase(matchRepository);

    // Courts
    final courtDataSource = CourtRemoteDataSource(apiClient);
    final courtRepository = CourtRepositoryImpl(courtDataSource);
    getCourtsUseCase = GetCourtsUseCase(courtRepository);

    // User Profile
    final userDataSource = UserProfileRemoteDataSource(apiClient);
    final userRepository = UserProfileRepositoryImpl(userDataSource);
    getMyUserProfileUseCase = GetMyUserProfileUseCase(userRepository);

    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final user = await getMyUserProfileUseCase.execute();
      final loadedCourts = await getCourtsUseCase.execute();

      setState(() {
        currentUser = user;
        courts = loadedCourts;
        if (courts.isNotEmpty) {
          _selectedCourtId = courts.first.id;
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error al cargar canchas o usuario. Reintenta.';
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.darkNavy,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.darkNavy,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona fecha y hora para el partido.')),
      );
      return;
    }
    if (_selectedCourtId == null || currentUser == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final matchDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final courtIdInt = int.parse(_selectedCourtId!);
      
      await createMatchUseCase.execute(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dateTime: matchDateTime,
        maxPlayers: _maxPlayers,
        courtId: courtIdInt,
        createdById: currentUser!.id,
      );

      // Successfully created
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Partido creado correctamente con éxito.'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear el partido: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Crear Partido',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(errorMessage!, style: const TextStyle(color: Colors.redAccent)),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Completa la información para tu encuentro deportivo.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        
                        // Title
                        TextFormField(
                          controller: _titleController,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Título del Partido',
                            hintText: 'Ej. Pichanga de los Viernes',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor ingresa un título.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Descripción / Reglas',
                            hintText: 'Ej. Traer camiseta blanca y negra, nivel intermedio.',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Court Selection
                        DropdownButtonFormField<String>(
                          value: _selectedCourtId,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'Seleccionar Cancha',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: courts.map((court) {
                            return DropdownMenuItem<String>(
                              value: court.id,
                              child: Text('${court.name} - ${court.district}'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedCourtId = val;
                            });
                          },
                        ),
                        const SizedBox(height: 18),

                        // Date & Time pickers
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _selectDate,
                                icon: const Icon(Icons.calendar_today, color: AppColors.primary),
                                label: Text(
                                  _selectedDate == null
                                      ? 'Elegir Fecha'
                                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                  style: const TextStyle(color: AppColors.textPrimary),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: const BorderSide(color: AppColors.border),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _selectTime,
                                icon: const Icon(Icons.access_time, color: AppColors.primary),
                                label: Text(
                                  _selectedTime == null
                                      ? 'Elegir Hora'
                                      : _selectedTime!.format(context),
                                  style: const TextStyle(color: AppColors.textPrimary),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: const BorderSide(color: AppColors.border),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Max Players Slider
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Límite de Jugadores',
                              style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '$_maxPlayers jugadores',
                              style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Slider(
                          value: _maxPlayers.toDouble(),
                          min: 2,
                          max: 22,
                          divisions: 20,
                          activeColor: AppColors.primary,
                          inactiveColor: AppColors.border,
                          onChanged: (val) {
                            setState(() {
                              _maxPlayers = val.round();
                            });
                          },
                        ),
                        const SizedBox(height: 18),

                        // Contact Invitations list
                        const Text(
                          'Invitar amigos o contactos',
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: _contacts.map((contact) {
                              return CheckboxListTile(
                                value: contact['selected'],
                                title: Text(contact['name'], style: const TextStyle(color: AppColors.textPrimary)),
                                activeColor: AppColors.primary,
                                checkColor: AppColors.darkNavy,
                                onChanged: (val) {
                                  setState(() {
                                    contact['selected'] = val ?? false;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        
                        const SizedBox(height: 40),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text(
                              'Crear Partido',
                              style: TextStyle(
                                color: AppColors.darkNavy,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
