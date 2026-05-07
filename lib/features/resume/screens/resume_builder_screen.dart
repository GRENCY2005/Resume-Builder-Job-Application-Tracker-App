import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:uuid/uuid.dart';

import '../models/resume_model.dart';
import '../providers/resume_provider.dart';

class ResumeBuilderScreen extends ConsumerStatefulWidget {
  /// If [existingResume] is provided, the screen acts as an editor.
  /// Otherwise, it creates a new resume.
  final ResumeModel? existingResume;

  const ResumeBuilderScreen({super.key, this.existingResume});

  @override
  ConsumerState<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends ConsumerState<ResumeBuilderScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  // Dynamic Lists State
  List<String> _skills = [];
  List<String> _education = [];
  List<String> _experience = [];

  // Controllers for dynamic input fields
  final _skillController = TextEditingController();
  final _educationController = TextEditingController();
  final _experienceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize state if we are editing an existing resume
    if (widget.existingResume != null) {
      _skills = List.from(widget.existingResume!.skills);
      _education = List.from(widget.existingResume!.education);
      _experience = widget.existingResume!.experience != null ? List.from(widget.existingResume!.experience!) : [];
    }
  }

  @override
  void dispose() {
    _skillController.dispose();
    _educationController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  void _saveResume() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;

      final newResume = ResumeModel(
        id: widget.existingResume?.id ?? const Uuid().v4(),
        fullName: formData['fullName'],
        email: formData['email'],
        phone: formData['phone'],
        address: formData['address'],
        objective: formData['objective'],
        skills: _skills,
        education: _education,
        experience: _experience.isNotEmpty ? _experience : null,
        createdAt: widget.existingResume?.createdAt ?? DateTime.now(),
      );

      if (widget.existingResume == null) {
        ref.read(resumeProvider.notifier).addResume(newResume);
      } else {
        ref.read(resumeProvider.notifier).editResume(newResume);
      }

      // Show success message and pop
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingResume == null ? 'Resume created successfully!' : 'Resume updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the errors in the form.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // --- Dynamic Input Helpers ---

  void _addItemToList(TextEditingController controller, List<String> list) {
    final text = controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        list.add(text);
        controller.clear();
      });
    }
  }

  void _removeItemFromList(int index, List<String> list) {
    setState(() {
      list.removeAt(index);
    });
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicListSection({
    required String title,
    required IconData icon,
    required List<String> items,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(title, icon),
            
            // Input Field & Add Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLines: maxLines,
                    decoration: InputDecoration(
                      hintText: hintText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () => _addItemToList(controller, items),
                  icon: const Icon(Icons.add),
                  tooltip: 'Add $title',
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Display Items
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'No items added yet.',
                  style: TextStyle(color: Theme.of(context).colorScheme.outline),
                ),
              ),
              
            // If it's skills, use Wrap, otherwise use ListView for longer texts
            if (title == 'Skills')
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: items.asMap().entries.map((entry) {
                  return Chip(
                    label: Text(entry.value),
                    onDeleted: () => _removeItemFromList(entry.key, items),
                    deleteIconColor: Theme.of(context).colorScheme.error,
                  );
                }).toList(),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    color: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: ListTile(
                      title: Text(items[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _removeItemFromList(index, items),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingResume != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Resume' : 'Build Resume'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Resume',
            onPressed: _saveResume,
          ),
        ],
      ),
      body: FormBuilder(
        key: _formKey,
        initialValue: {
          'fullName': widget.existingResume?.fullName ?? '',
          'email': widget.existingResume?.email ?? '',
          'phone': widget.existingResume?.phone ?? '',
          'address': widget.existingResume?.address ?? '',
          'objective': widget.existingResume?.objective ?? '',
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Personal Details ---
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildSectionHeader('Personal Details', Icons.person_outline),
                      FormBuilderTextField(
                        name: 'fullName',
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'email',
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.email(),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'phone',
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        keyboardType: TextInputType.phone,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'address',
                        decoration: InputDecoration(
                          labelText: 'Address',
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- Career Objective ---
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildSectionHeader('Career Objective', Icons.track_changes),
                      FormBuilderTextField(
                        name: 'objective',
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Describe your career goals...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- Skills (Dynamic) ---
              _buildDynamicListSection(
                title: 'Skills',
                icon: Icons.star_border,
                items: _skills,
                controller: _skillController,
                hintText: 'e.g. Flutter, Dart, Leadership',
              ),
              const SizedBox(height: 16),

              // --- Education (Dynamic) ---
              _buildDynamicListSection(
                title: 'Education',
                icon: Icons.school_outlined,
                items: _education,
                controller: _educationController,
                hintText: 'e.g. BSc Computer Science - XYZ University',
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // --- Experience (Dynamic) ---
              _buildDynamicListSection(
                title: 'Experience',
                icon: Icons.work_outline,
                items: _experience,
                controller: _experienceController,
                hintText: 'e.g. Software Engineer at ABC Corp (2020-2023)',
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // --- Save Button ---
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: _saveResume,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text(
                    'Save Resume',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
