import Component from "@ember/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { tagName } from "@ember-decorators/component";
import DButton from "discourse/components/d-button";
import routeAction from "discourse/helpers/route-action";
import discourseComputed from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";

@tagName("")
export default class TopicInGatedCategory extends Component {
  @service router;

  hidden = true;
  enabledCategories = settings.enabled_categories
    .split("|")
    .map((id) => parseInt(id, 10))
    .filter((id) => id);
  enabledTags = settings.enabled_tags.split("|").filter(Boolean);

  didInsertElement() {
    super.didInsertElement(...arguments);
    this.recalculate();
  }

  didUpdateAttrs() {
    super.didUpdateAttrs(...arguments);
    this.recalculate();
  }

  willDestroyElement() {
    super.willDestroyElement(...arguments);
    document.body.classList.remove("topic-in-gated-category");
  }

  isUserInInsidersGroup() {
    if (!this.currentUser || !this.currentUser.groups) {
      return false;
    }

    return this.currentUser.groups.some((g) => g.name === "insider");
  }

  recalculate() {
    const pageType = this.pageType; // "topic" | "directory" | "profile"

    const isAnonymous = !this.currentUser;
    const isAdmin = this.currentUser?.admin;
    const isInsider = this.isUserInInsidersGroup();

    const isOwnProfile =
      pageType === "profile" &&
      this.profileUser &&
      this.profileUser.id === this.currentUser?.id;

    // 1. Anonymous → always gated
    if (isAnonymous) {
      document.body.classList.add("topic-in-gated-category");
      this.set("hidden", false);
      return;
    }

    // 2. Admin → never gated
    if (isAdmin) {
      document.body.classList.remove("topic-in-gated-category");
      this.set("hidden", true);
      return;
    }

    // 3. User Profile page logic
    if (pageType === "profile") {
      if (isOwnProfile) {
        // own profile → always allowed
        document.body.classList.remove("topic-in-gated-category");
        this.set("hidden", true);
        return;
      }

      // viewing someone else's profile
      if (isInsider) {
        document.body.classList.remove("topic-in-gated-category");
        this.set("hidden", true);
        return;
      }

      // non-insider → gated
      document.body.classList.add("topic-in-gated-category");
      this.set("hidden", false);
      return;
    }

    // 4. User Directory page logic
    if (pageType === "directory") {
      if (isInsider) {
        document.body.classList.remove("topic-in-gated-category");
        this.set("hidden", true);
        return;
      }

      // non-insider → gated
      document.body.classList.add("topic-in-gated-category");
      this.set("hidden", false);
      return;
    }

    // 5. Topic page logic (category/tag based)
    if (pageType === "topic") {
      const gatedByTag = this.tags?.some((t) => this.enabledTags.includes(t));

      const gatedByCategory = this.enabledCategories.includes(this.categoryId);

      const topicIsGated = gatedByTag || gatedByCategory;

      if (!topicIsGated) {
        return; // no gate on this topic
      }

      if (isInsider) {
        document.body.classList.remove("topic-in-gated-category");
        this.set("hidden", true);
        return;
      }

      // non-insider → gated
      document.body.classList.add("topic-in-gated-category");
      this.set("hidden", false);
      return;
    }
  }

  @discourseComputed("hidden")
  shouldShow(hidden) {
    return !hidden;
  }

  @action
  redirectToSignup() {
    window.open(
      i18n(themePrefix("sign_up_redirect_url")),
      "_blank",
      "noopener"
    );
  }

  <template>
    {{#if this.shouldShow}}
      <div class="custom-gated-topic-container">
        <div class="custom-gated-topic-content">
          <div class="custom-gated-topic-content--header">
            {{i18n (themePrefix "heading_text")}}
          </div>

          <p class="custom-gated-topic-content--text">
            {{i18n (themePrefix "subheading_text")}}
          </p>

          <div class="custom-gated-topic-content--cta">
            <div class="custom-gated-topic-content--cta__signup">
              <DButton
                @action={{this.redirectToSignup}}
                class="btn-primary btn-large sign-up-button"
                @translatedLabel={{i18n (themePrefix "signup_cta_label")}}
              />
            </div>

            <div class="custom-gated-topic-content--cta__login">
              <DButton
                @action={{routeAction "showLogin"}}
                @id="cta-login-link"
                class="btn btn-text login-button"
                @translatedLabel={{i18n (themePrefix "login_cta_label")}}
              />
            </div>
          </div>
        </div>
      </div>
    {{/if}}
  </template>
}
