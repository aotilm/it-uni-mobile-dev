enum EditForms {
  generalData,
  educationData, 
  armyService,
  jobActivity,
  parentsInfo,
  socialActivity,
  circleActivity,
  individualEscort,
  encouragement,
  socialPassport,
  workPlan,
  addStudent,
  addCurator,
  addGroup,
  addCategory
}

extension EditFormsExtension on EditForms {
  String get name {
    switch (this) {
      case EditForms.generalData:
        return "Загальні дані";
      case EditForms.educationData:
        return "Дані про освіту";
      case EditForms.armyService:
        return "Служба в ЗСУ";
      case EditForms.jobActivity:
        return "Трудова діяльність";
      case EditForms.parentsInfo:
        return "Інформація про батьків";
      case EditForms.socialActivity:
        return "Громадська діяльність";
      case EditForms.circleActivity:
        return "Гурткова діяльність";
      case EditForms.individualEscort:
        return "Індивідуальний супровід";
      case EditForms.encouragement:
        return "Заохочення";
      case EditForms.socialPassport:
        return "Соціальний паспорт";
      case EditForms.workPlan:
        return "План роботи";
      case EditForms.addStudent:
        return "Додавання студента";
      case EditForms.addCurator:
        return "Додавання куратора";
      case EditForms.addGroup:
        return "Додавання групи";
      case EditForms.addCategory:
        return "Додавання категорії";
    }
  }
} 