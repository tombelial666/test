import { Component, For, onCleanup, onMount, createEffect, Accessor } from "solid-js";
import { useLocalization } from "@etna-widget/localization";
import { CheckboxTitles, QueryParams, FilterCheckbox, allFilterCheckboxes } from "app/scenes/AccountDocuments/types";
import Litepicker from 'litepicker';
import 'litepicker/dist/plugins/mobilefriendly';
import styles from "./Filters.css?inline";

type Props = {
  queryParams: Accessor<QueryParams>;
  availableCheckboxes?: FilterCheckbox[] | null;
  onFiltersChange: (name: keyof QueryParams, value: QueryParams[keyof QueryParams]) => void;
}

export const Filters: Component<Props> = (props) => {
  const { t } = useLocalization();
  const checkboxes = () => props.availableCheckboxes ?? allFilterCheckboxes;

  const getCheckboxLabel = (checkbox: keyof typeof CheckboxTitles) => {
    switch (checkbox) {
      case 'includeAccountStatements':
        return t('includeAccountStatements');
      case 'includeTaxForms':
        return t('includeTaxForms');
      case 'includeTradeConfirmations':
        return t('includeTradeConfirmations');
      case 'includeConfirmationLetter':
        return t('includeConfirmationLetter');
      default:
        return CheckboxTitles[checkbox];
    }
  };
  const litepickerDropdownOptions = { minYear: 1970, maxYear: new Date().getFullYear(), months: true, years: true };

  const handler = (event) => {
    const {
      name,
      checked
    } = event.target;

    props.onFiltersChange(name, checked);
  };

  let startDateRef!: HTMLInputElement;
  let endDateRef!: HTMLInputElement;
  let startDatePicker: Litepicker;
  let endDatePicker: Litepicker;

  onMount(() => {
    const createDatePicker = (element: HTMLInputElement, initialDate: string, filterType: 'startDate' | 'endDate') => {
      return new Litepicker({
        dropdowns: litepickerDropdownOptions,
        singleMode: true,
        element: element,
        plugins: ['mobilefriendly'],
        startDate: initialDate,
        lockDaysFilter: (date) => {
            if (date === null) return true;
            const inputDate = date.toJSDate();
            const today = new Date();
            const year1970 = new Date(1970, 0, 1);
            return inputDate < year1970 || inputDate > today;
        },
        format: "MM/DD/YYYY",
        setup: (picker) => {
          picker.on('selected', (dateObj) => {
            const selectedDate = dateObj.dateInstance;
            if (filterType == "endDate") {
              selectedDate.setHours(23, 59, 59);
            }

            const formattedDate = selectedDate.toISOString();
            props.onFiltersChange(filterType, formattedDate);
          })
        },
      });
    };

    startDatePicker = createDatePicker(startDateRef, props.queryParams().startDate, "startDate");
    endDatePicker = createDatePicker(endDateRef, props.queryParams().endDate, "endDate");
  });

  createEffect(() => {
    if (startDatePicker) {
      const startDate = new Date(props.queryParams().startDate);
      startDatePicker.setOptions({startDate});
    }
  })

  onCleanup(() => {
    startDatePicker.destroy();
    endDatePicker.destroy();
  });

  return (
    <div class="filters">
      <style>{styles}</style>
      <div class="filters__date-container">
        <label>{t('date')}: </label>
        <div class="filters__data">
          <input type="text" readonly={true} ref={startDateRef}/>
        </div>
        <span> - </span>
        <div class="filters__data">
          <input type="text" readonly={true} ref={endDateRef}/>
        </div>
      </div>
      <ul class="filters__checkboxes">
        <For each={checkboxes()}>{(checkbox) => (
          <li class="filters__checkbox-group">
            <input
              class="filters__checkbox"
              id={checkbox}
              type="checkbox"
              name={checkbox}
              checked={props.queryParams()[checkbox]}
              onChange={handler}
            />
            <label
              class="filters__checkbox-label"
              for={checkbox}
            >
              {getCheckboxLabel(checkbox)}
            </label>
          </li>
        )}</For>
      </ul>
    </div>
  );
};
