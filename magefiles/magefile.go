//go:build mage

package main

import (
	"fmt"
	"os"

	"github.com/bitfield/script"
	"github.com/fatih/color"
	utils "github.com/l50/goutils"

	// mage utility functions
	"github.com/magefile/mage/mg"
)

func init() {
	os.Setenv("GO111MODULE", "on")
}

// InstallDeps Installs project dependencies
func InstallDeps() error {
	fmt.Println(color.YellowString("Installing dependencies."))
	utils.Cd("magefiles")

	if err := utils.Tidy(); err != nil {
		return fmt.Errorf(color.RedString(
			"failed to install dependencies: %v", err))
	}

	return nil
}

// InstallPreCommitHooks Installs pre-commit hooks locally
func InstallPreCommitHooks() error {
	mg.Deps(InstallDeps)

	fmt.Println(color.YellowString("Installing pre-commit hooks."))
	if err := utils.InstallPCHooks(); err != nil {
		return err
	}

	return nil
}

// RunPreCommit runs all pre-commit hooks locally
func RunPreCommit() error {
	mg.Deps(InstallDeps)

	fmt.Println(color.YellowString("Updating pre-commit hooks."))
	if err := utils.UpdatePCHooks(); err != nil {
		return err
	}

	fmt.Println(color.YellowString(
		"Clearing the pre-commit cache to ensure we have a fresh start."))
	if err := utils.ClearPCCache(); err != nil {
		return err
	}

	fmt.Println(color.YellowString("Running all pre-commit hooks locally."))
	if err := utils.RunPCHooks(); err != nil {
		return err
	}

	return nil
}

func runCmds(cmds []string) error {
	for _, cmd := range cmds {
		if _, err := script.Exec(cmd).Stdout(); err != nil {
			return err
		}
	}

	return nil

}

// LintAnsible runs ansible-lint.
func LintAnsible() error {
	cmds := []string{
		"ansible-lint --force-color -c .hooks/linters/.ansible-lint",
	}

	fmt.Println(color.YellowString("Running ansible-lint."))
	if err := runCmds(cmds); err != nil {
		return fmt.Errorf(color.RedString("failed to run ansible-lint: %v", err))
	}

	return nil
}

// RunMoleculeTests runs the molecule tests.
func RunMoleculeTests() error {
	cmds := []string{
		"molecule create",
		"molecule converge",
		"molecule idempotence",
		"molecule destroy",
	}

	fmt.Println(color.YellowString("Running molecule tests."))
	if err := runCmds(cmds); err != nil {
		return fmt.Errorf(color.RedString("failed to run molecule tests: %v", err))
	}

	return nil
}
