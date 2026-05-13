import { Component } from "solid-js";
import styles from "./Button.css?inline";

type Props = {
  text: string;
  onClick: () => void;
};

export const Button: Component<Props> = (props) => {
  return (
    <>
      <style>{styles}</style>

      <button
        class="button"
        type="button"
        onClick={props.onClick}
      >
        {props.text}
      </button>
    </>
  );
};
